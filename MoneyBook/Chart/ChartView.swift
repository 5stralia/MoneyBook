//
//  ChartView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/08/10.
//

import Foundation
import Charts
import SwiftUI

fileprivate struct ValuePerCategory {
    var category: String
    var value: Double
}

fileprivate struct ChartData: Identifiable {
    let category: String
    let value: Double
    let yearMonth: String
    
    let id: UUID = UUID()
}

struct ChartView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemCoreEntity.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ItemCoreEntity>
    
    @State private var year = 2023
    @State private var month = 1
    @State private var chartVisibleLength = 4
    @State private var selectedExpenseCategories = ["category0"]
    @State private var selectedIncomeCategories = ["category0"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                StatisticsChart(
                    title: "지출",
                    selectedCategories: self.selectedExpenseCategories,
                    items: self.incomeData(self.items.map({ $0 }), year: year, month: month, length: chartVisibleLength)
                )
                
                StatisticsChart(
                    title: "소득",
                    selectedCategories: self.selectedIncomeCategories,
                    items: self.expendData(self.items.map({ $0 }), year: year, month: month, length: chartVisibleLength))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("plus", systemImage: self.chartVisibleLength == 8 ? "minus.magnifyingglass" : "plus.magnifyingglass") {
                        if self.chartVisibleLength == 8 {
                            self.chartVisibleLength = 2
                        } else {
                            self.chartVisibleLength += 2
                        }
                    }
                }
            }
            .toolbar(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Chart")
        }
        .onAppear(perform: {
            let date = Date()
            self.year = date.getYear()
            self.month = date.getMonth()
        })
    }
    
    private func incomeData(_ items: [ItemCoreEntity], year: Int, month: Int, length: Int) -> [ChartData] {
        var result: [ChartData] = []
        
        let items = items.filter { item in
            let minDiff = month - length
            let minMonth = (minDiff <= 0) ? (12 + minDiff) : minDiff
            let minYear = (minDiff <= 0) ? (year - 1) : year
            
            let maxDiff = month + length
            let maxMonth = (maxDiff > 12) ? (maxDiff - 12) : maxDiff
            let maxYear = (maxDiff > 12) ? (year + 1) : year
            
            guard let minDate = Calendar.current.date(from: DateComponents(year: minYear, month: minMonth)),
                  let maxDate = Calendar.current.date(from: DateComponents(year: maxYear, month: maxMonth))
            else {
                return false
            }
            
            return item.amount >= 0 &&
            minDate <= item.timestamp &&
            item.timestamp <= maxDate
        }
        
        let grouping = Dictionary(grouping: items, by: { $0.category })
        for (category, values) in grouping {
            let gp = Dictionary(grouping: values, by: { "\($0.timestamp.getYear()). \($0.timestamp.getMonth())" })
            for (yearMonth, values2) in gp {
                result.append(ChartData(category: category, value: values2.map(\.amount).reduce(0, +), yearMonth: yearMonth))
            }
        }
        
        return result.sorted(using: KeyPathComparator(\.yearMonth))
    }
    
    private func expendData(_ items: [ItemCoreEntity], year: Int, month: Int, length: Int) -> [ChartData] {
        var result: [ChartData] = []
        
        let items = items.filter { item in
            let minDiff = month - length
            let minMonth = (minDiff <= 0) ? (12 + minDiff) : minDiff
            let minYear = (minDiff <= 0) ? (year - 1) : year
            
            let maxDiff = month + length
            let maxMonth = (maxDiff > 12) ? (maxDiff - 12) : maxDiff
            let maxYear = (maxDiff > 12) ? (year + 1) : year
            
            guard let minDate = Calendar.current.date(from: DateComponents(year: minYear, month: minMonth)),
                  let maxDate = Calendar.current.date(from: DateComponents(year: maxYear, month: maxMonth))
            else {
                return false
            }
            
            return item.amount < 0 &&
            minDate <= item.timestamp &&
            item.timestamp <= maxDate
        }
        let grouping = Dictionary(grouping: items, by: { $0.category })
        for (category, values) in grouping {
            let gp = Dictionary(grouping: values, by: { "\($0.timestamp.getYear()). \($0.timestamp.getMonth())" })
            for (yearMonth, values2) in gp {
                result.append(ChartData(category: category, value: values2.map(\.amount).reduce(0, -), yearMonth: yearMonth))
            }
        }
        
        return result.sorted(using: KeyPathComparator(\.yearMonth))
    }
}

struct StatisticsChart: View {
    var title: String
    var selectedCategories: [String]
    fileprivate var items: [ChartData]

    var body: some View {
        HStack {
            Text(self.title)
                .font(.title)
            Spacer()
            Button(action: {
                
            }, label: {
                Text(self.selectedCategories.joined(separator: ", "))
            })
        }
        .padding([.leading, .trailing], 16)
            
        Chart {
            ForEach(items) { item in
                BarMark(
                    x: .value("month", item.yearMonth),
                    y: .value("amount", item.value)
                )
                .foregroundStyle(by: .value("category", item.category))
            }
        }
        .frame(height: 200)
        .padding(.all, 8)
    }
}

extension Date {
    fileprivate func getYear() -> Int {
        return Calendar.current.component(.year, from: self)
    }
    
    fileprivate func getMonth() -> Int {
        return Calendar.current.component(.month, from: self)
    }
}

private let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
