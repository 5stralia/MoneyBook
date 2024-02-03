//
//  ChartView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/08/10.
//

import Charts
import Foundation
import SwiftData
import SwiftUI

enum Recording {
    case expense
    case income
}

struct ChartView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Query var items: [ItemCoreEntity]

    @State private var year = Date().getYear()
    @State private var month = Date().getMonth()
    @State private var isExpense = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Header(topText: "월별 \(self.isExpense ? "지출" : "소득")", title: "\(self.year).\(self.month)", action: {})

                ScrollView {
                    VStack(spacing: 0) {
                        ChangingGraph(
                            items: Array(self.items).statisticsByMonth(targetYear: self.year, targetMonth: self.month)
                        )
                        .padding([.top, .bottom], 20)
                        .frame(height: 160)
                        .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))
                        MonthlySummaryView(
                            monthlyCategoryItems: self.groupedByCategory(
                                items: self.items.map({ $0 }), isExpense: self.isExpense)
                        )
                        .frame(height: 240)
                        .padding([.leading, .trailing], 20)
                        .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))

                        ForEach(self.groupedByCategory(items: self.items.map({ $0 }), isExpense: self.isExpense)) {
                            item in
                            NavigationLink(value: item) {
                                MonthlyCategoryItemView(item: item)
                                    .frame(height: 46)
                                    .padding(.leading, 20)
                                    .padding(.trailing, 14)
                            }
                        }
                        .navigationDestination(
                            for: MonthlyCategoryItem.self,
                            destination: { item in
                                CategoryStatisticsView(year: self.year, month: self.month, category: item.title)
                            })
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .onAppear(perform: {
            let date = Date()
            self.year = date.getYear()
            self.month = date.getMonth()
        })
    }

    private func groupedByCategory(items: [ItemCoreEntity], isExpense: Bool) -> [MonthlyCategoryItem] {
        let items = items.filter { isExpense ? ($0.amount < 0) : ($0.amount >= 0) }
        let sum = items.map(\.amount).reduce(0, +)

        let dict = Dictionary(grouping: items, by: { $0.category })
        return dict.enumerated().map { (offset, dict) in
            let (category, items) = dict
            let categorySum = items.map(\.amount).reduce(0, +)
            let random = { stride(from: 0.0, to: 1.0, by: 0.01).map({ $0 }).randomElement() ?? 0 }
            let color =
                if offset < 7 {
                    Color.brownColors[offset]
                } else {
                    Color(red: random(), green: random(), blue: random())
                }

            return MonthlyCategoryItem(
                ratio: Float(categorySum / sum), title: category.title, value: categorySum, color: color)
        }
    }

    //    private func getTopExpenseCategory(items: [ItemCoreEntity], year: Int, month: Int) -> MonthlySummaryItem {
    //        let targetItems = items.filter { $0.timestamp.getYear() == year && $0.timestamp.getMonth() == month }
    //
    //    }
}

extension Date {
    func getYear() -> Int {
        return Calendar.current.component(.year, from: self)
    }

    func getMonth() -> Int {
        return Calendar.current.component(.month, from: self)
    }

    func getDay() -> Int {
        return Calendar.current.component(.day, from: self)
    }
}

private let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()

#Preview {
    ChartView()
        .modelContainer(PersistenceController.preview.container)
}
