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
    
    var body: some View {
        ScrollView {
            Chart {
                ForEach(self.incomeData(self.items.map({ $0 }))) { item in
                    BarMark(
                        x: .value("month", item.yearMonth),
                        y: .value("amount", item.value)
                    )
                    .foregroundStyle(by: .value("category", item.category))
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 5)
            
            
            Chart {
                ForEach(self.expendData(self.items.map({ $0 }))) { item in
                    BarMark(
                        x: .value("month", item.yearMonth),
                        y: .value("amount", -item.value)
                    )
                    .foregroundStyle(by: .value("category", item.category))
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 5)
        }
    }
    
    private func incomeData(_ items: [ItemCoreEntity]) -> [ChartData] {
        var result: [ChartData] = []
        
        let items = items.filter { $0.amount >= 0 }
        let grouping = Dictionary(grouping: items, by: { $0.category })
        for (category, values) in grouping {
            let gp = Dictionary(grouping: values, by: { "\($0.timestamp.getYear()). \($0.timestamp.getMonth())" })
            for (yearMonth, values2) in gp {
                result.append(ChartData(category: category, value: values2.map(\.amount).reduce(0, +), yearMonth: yearMonth))
            }
        }
        
        return result.sorted(using: KeyPathComparator(\.yearMonth))
    }
    
    private func expendData(_ items: [ItemCoreEntity]) -> [ChartData] {
        var result: [ChartData] = []
        
        let items = items.filter { $0.amount < 0 }
        let grouping = Dictionary(grouping: items, by: { $0.category })
        for (category, values) in grouping {
            let gp = Dictionary(grouping: values, by: { "\($0.timestamp.getYear()). \($0.timestamp.getMonth())" })
            for (yearMonth, values2) in gp {
                result.append(ChartData(category: category, value: values2.map(\.amount).reduce(0, +), yearMonth: yearMonth))
            }
        }
        
        return result.sorted(using: KeyPathComparator(\.yearMonth))
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
