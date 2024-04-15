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
    @Environment(\.modelContext) var modelContext
    @Query var items: [ItemCoreEntity]

    @State private var year = Date().getYear()
    @State private var month = Date().getMonth()
    @State private var isExpense = true

    @State var isHiddenPicker: Bool = true

    private var prevMonthlyCategorySummary: [String: Double] {
        let comp = DateComponents(year: self.year, month: self.month)
        guard let current = Calendar.current.date(from: comp),
            let prevDate = Calendar.current.date(byAdding: .month, value: -1, to: current)
        else { return [:] }

        let filterdItems = self.items
            .filter { item in
                return item.timestamp.getYear() == prevDate.getYear()
                    && item.timestamp.getMonth() == prevDate.getMonth()
            }

        let group = Dictionary(grouping: filterdItems, by: { $0.category })
        let group2 = group.mapValues({ items in items.reduce(0, { $0 + $1.amount }) })

        var result: [String: Double] = [:]
        group2.forEach { (item, totalValue) in
            result.updateValue(totalValue, forKey: item.title)
        }

        return result
    }
    private var monthlyCategoryItems: [MonthlyCategoryItem] {
        let filteredItems = self.items
            .filter { item in
                return item.category.isExpense == self.isExpense && item.timestamp.getYear() == self.year
                    && item.timestamp.getMonth() == self.month
            }

        return self.groupedByCategory(items: filteredItems)
            .sorted(using: KeyPathComparator(\.value, order: .reverse))
            .enumerated()
            .map({ offset, item in
                let random = { stride(from: 0.0, to: 1.0, by: 0.01).map({ $0 }).randomElement() ?? 0 }
                let color =
                    if offset < 7 {
                        Color.brownColors[offset]
                    } else {
                        Color(red: random(), green: random(), blue: random())
                    }

                return MonthlyCategoryItem(ratio: item.ratio, title: item.title, value: item.value, color: color)
            })
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Header(
                        topText: "월별 \(self.isExpense ? "지출" : "소득")",
                        title: "\(self.year).\(self.month)",
                        action: {
                            self.isHiddenPicker.toggle()
                        },
                        backgroundColor: .headerColor(isExpense: self.isExpense)
                    )
                    .trailingContent({
                        Button(
                            action: {
                                self.isExpense.toggle()
                            },
                            label: {
                                Text(self.isExpense ? "지출" : "소득")
                                    .font(.Pretendard(size: 18))
                                    .foregroundStyle(.white)
                            })
                    })

                    ScrollView {
                        VStack(spacing: 0) {
                            ChangingGraph(
                                items: Array(self.items.filter({ $0.category.isExpense == self.isExpense }))
                                    .statisticsByMonth(targetYear: self.year, targetMonth: self.month)
                            )
                            .padding([.top, .bottom], 20)
                            .frame(height: 160)
                            .background(Color.backgroundColor(isExpense: self.isExpense))

                            let prevMonthlyCategorySummary = self.prevMonthlyCategorySummary
                            let monthlyCategoryItems = self.monthlyCategoryItems
                            MonthlySummaryView(
                                isExpense: self.isExpense,
                                prevMonthlyCategorySummary: prevMonthlyCategorySummary,
                                monthlyCategoryItems:
                                    monthlyCategoryItems
                                    .map({
                                        MonthlySummaryViewChartItem(title: $0.title, value: $0.value, color: $0.color)
                                    })
                            )
                            .frame(height: 240)
                            .padding([.leading, .trailing], 20)
                            .background(Color.backgroundColor(isExpense: self.isExpense))

                            ForEach(monthlyCategoryItems) { item in
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

                if !isHiddenPicker {
                    VStack(spacing: 5) {
                        HStack {
                            Picker("Year", selection: $year) {
                                ForEach((2000...2100), id: \.self) { i in
                                    Text(String(i))
                                }
                            }
                            .pickerStyle(.wheel)
                            Picker("Month", selection: $month) {
                                ForEach((1...12), id: \.self) { i in
                                    Text(String(i))
                                }
                            }
                            .pickerStyle(.wheel)
                        }

                        Button {
                            withAnimation {
                                self.isHiddenPicker.toggle()
                            }
                        } label: {
                            Text("Done")
                        }

                    }
                    .padding(.bottom, 32)
                    .background(.background)
                    .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
                    .shadow(radius: 8)
                }
            }
        }
        .onAppear(perform: {
            let date = Date()
            self.year = date.getYear()
            self.month = date.getMonth()
        })
    }

    private func groupedByCategory(items: [ItemCoreEntity]) -> [MonthlyCategoryItem] {
        let items = items.filter { $0.category.isExpense == isExpense }
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
