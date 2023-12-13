//
//  ChartView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/08/10.
//

import Charts
import Foundation
import SwiftUI

private struct ValuePerCategory {
    var category: String
    var value: Double
}

private struct ChartData: Identifiable {
    let category: String
    let value: Double
    let yearMonth: String

    let id: UUID = UUID()
}

enum Recording {
    case expense
    case income
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

    @State private var isItemsLoaded: Bool = false
    @State private var selection1: [String] = []
    @State private var selection2: [String] = []

    @State private var pickerSelection: Recording = .expense

    var body: some View {
        NavigationStack {
            ScrollView {

                Picker("type", selection: $pickerSelection) {
                    Text("지출").tag(Recording.expense)
                    Text("소득").tag(Recording.income)
                }
                .pickerStyle(.segmented)

                Spacer(minLength: 20)

                if self.pickerSelection == .expense {
                    CategoryPieChart(
                        items: self.filterCurrentMonthItems(
                            self.items.map({ $0 }), year: self.year, month: self.month, isIncome: false)
                    )
                    .frame(height: 200)

                    Spacer(minLength: 20)

                    StatisticsChart(
                        title: "지출",
                        selectedCategories: self.selection1,
                        items: self.filteredItems(
                            self.items.map({ $0 }),
                            year: year,
                            month: month,
                            length: self.chartVisibleLength,
                            isIncome: false,
                            selctedCategories: self.selection1
                        ),
                        destination: {
                            MultiSelectView(
                                items: self.getAllCategories(isIncome: false)
                                    .map { category in
                                        let selected = self.selection1
                                        return SelectionItem(name: category, isSelected: selected.contains(category))
                                    },
                                selection: self._selection1
                            )
                        }
                    )
                } else {
                    CategoryPieChart(
                        items: self.filterCurrentMonthItems(
                            self.items.map({ $0 }), year: self.year, month: self.month, isIncome: true)
                    )
                    .frame(height: 200)

                    Spacer(minLength: 20)

                    StatisticsChart(
                        title: "소득",
                        selectedCategories: self.selection2,
                        items: self.filteredItems(
                            self.items.map({ $0 }),
                            year: year,
                            month: month,
                            length: self.chartVisibleLength,
                            isIncome: true,
                            selctedCategories: self.selection2
                        ),
                        destination: {
                            MultiSelectView(
                                items: self.getAllCategories(isIncome: true)
                                    .map { category in
                                        let selected = self.selection2
                                        return SelectionItem(name: category, isSelected: selected.contains(category))
                                    },
                                selection: self._selection2
                            )
                        }
                    )
                }
            }
            .padding([.leading, .trailing], 8)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        "plus",
                        systemImage: self.chartVisibleLength == 8
                            ? "plus.magnifyingglass" : "minus.magnifyingglass"
                    ) {
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

            if !self.isItemsLoaded {
                if self.selection1.isEmpty { self.selection1 = self.getAllCategories(isIncome: false) }
                if self.selection2.isEmpty { self.selection2 = self.getAllCategories(isIncome: true) }

                self.isItemsLoaded = true
            }
        })
    }

    private func getAllCategories(isIncome: Bool) -> [String] {
        let filtered = self.items.filter { item in
            if isIncome {
                return item.amount >= 0
            } else {
                return item.amount < 0
            }
        }

        return Dictionary(grouping: filtered, by: { $0.category }).map { $0.key }
    }

    private func filterCurrentMonthItems(
        _ items: [ItemCoreEntity],
        year: Int,
        month: Int,
        isIncome: Bool
    ) -> [ChartData] {
        let items = items.filter { $0.timestamp.getYear() == year && $0.timestamp.getMonth() == month }
            .filter { isIncome ? $0.amount < 0 : $0.amount >= 0 }

        let grouping = Dictionary(grouping: items, by: { $0.category })
        return grouping.map { (key, value) in
            ChartData(
                category: key,
                value: value.filter({ isIncome ? $0.amount < 0 : $0.amount > 0 })
                    .map({ isIncome ? -$0.amount : $0.amount })
                    .reduce(0, +),
                yearMonth: "\(year). \(month)"
            )
        }
    }

    private func filteredItems(
        _ items: [ItemCoreEntity],
        year: Int,
        month: Int,
        length: Int,
        isIncome: Bool,
        selctedCategories: [String]
    ) -> [ChartData] {
        var result: [ChartData] = []

        let items = items.filter { item in
            let minDiff = month - length
            let minMonth = (minDiff <= 0) ? (12 + minDiff) : minDiff
            let minYear = (minDiff <= 0) ? (year - 1) : year

            let maxDiff = month + length
            let maxMonth = (maxDiff > 12) ? (maxDiff - 12) : maxDiff
            let maxYear = (maxDiff > 12) ? (year + 1) : year

            guard
                let minDate = Calendar.current.date(from: DateComponents(year: minYear, month: minMonth)),
                let maxDate = Calendar.current.date(from: DateComponents(year: maxYear, month: maxMonth))
            else {
                return false
            }

            if isIncome {
                return item.amount >= 0 && minDate <= item.timestamp && item.timestamp <= maxDate
            } else {
                return item.amount < 0 && minDate <= item.timestamp && item.timestamp <= maxDate
            }
        }
        .filter { selctedCategories.contains($0.category) }

        let grouping = Dictionary(grouping: items, by: { $0.category })
        for (category, values) in grouping {
            let gp = Dictionary(
                grouping: values, by: { "\($0.timestamp.getYear()). \($0.timestamp.getMonth())" })
            for (yearMonth, values2) in gp {
                if isIncome {
                    result.append(
                        ChartData(
                            category: category, value: values2.map(\.amount).reduce(0, +), yearMonth: yearMonth))
                } else {
                    result.append(
                        ChartData(
                            category: category, value: values2.map(\.amount).reduce(0, -), yearMonth: yearMonth))
                }
            }
        }

        return result.sorted(using: KeyPathComparator(\.yearMonth))
    }

    private func incomeData(_ items: [ItemCoreEntity], year: Int, month: Int, length: Int)
        -> [ChartData]
    {
        var result: [ChartData] = []

        let items = items.filter { item in
            let minDiff = month - length
            let minMonth = (minDiff <= 0) ? (12 + minDiff) : minDiff
            let minYear = (minDiff <= 0) ? (year - 1) : year

            let maxDiff = month + length
            let maxMonth = (maxDiff > 12) ? (maxDiff - 12) : maxDiff
            let maxYear = (maxDiff > 12) ? (year + 1) : year

            guard
                let minDate = Calendar.current.date(from: DateComponents(year: minYear, month: minMonth)),
                let maxDate = Calendar.current.date(from: DateComponents(year: maxYear, month: maxMonth))
            else {
                return false
            }

            return item.amount >= 0 && minDate <= item.timestamp && item.timestamp <= maxDate
        }

        let grouping = Dictionary(grouping: items, by: { $0.category })
        for (category, values) in grouping {
            let gp = Dictionary(
                grouping: values, by: { "\($0.timestamp.getYear()). \($0.timestamp.getMonth())" })
            for (yearMonth, values2) in gp {
                result.append(
                    ChartData(
                        category: category, value: values2.map(\.amount).reduce(0, +), yearMonth: yearMonth))
            }
        }

        return result.sorted(using: KeyPathComparator(\.yearMonth))
    }

    private func expendData(_ items: [ItemCoreEntity], year: Int, month: Int, length: Int)
        -> [ChartData]
    {
        var result: [ChartData] = []

        let items = items.filter { item in
            let minDiff = month - length
            let minMonth = (minDiff <= 0) ? (12 + minDiff) : minDiff
            let minYear = (minDiff <= 0) ? (year - 1) : year

            let maxDiff = month + length
            let maxMonth = (maxDiff > 12) ? (maxDiff - 12) : maxDiff
            let maxYear = (maxDiff > 12) ? (year + 1) : year

            guard
                let minDate = Calendar.current.date(from: DateComponents(year: minYear, month: minMonth)),
                let maxDate = Calendar.current.date(from: DateComponents(year: maxYear, month: maxMonth))
            else {
                return false
            }

            return item.amount < 0 && minDate <= item.timestamp && item.timestamp <= maxDate
        }
        let grouping = Dictionary(grouping: items, by: { $0.category })
        for (category, values) in grouping {
            let gp = Dictionary(
                grouping: values, by: { "\($0.timestamp.getYear()). \($0.timestamp.getMonth())" })
            for (yearMonth, values2) in gp {
                result.append(
                    ChartData(
                        category: category, value: values2.map(\.amount).reduce(0, -), yearMonth: yearMonth))
            }
        }

        return result.sorted(using: KeyPathComparator(\.yearMonth))
    }
}

struct CategoryPieChart: View {
    fileprivate var items: [ChartData]

    var body: some View {
        Chart {
            ForEach(items) { item in
                SectorMark(
                    angle: .value("category", item.value),
                    innerRadius: .ratio(0.6),
                    outerRadius: .ratio(1.0),
                    angularInset: 10
                )
                .foregroundStyle(by: .value("category", item.category))
            }
        }
    }
}

struct StatisticsChart<Destination>: View where Destination: View {
    var title: String
    var selectedCategories: [String]
    fileprivate var items: [ChartData]

    @ViewBuilder var destination: () -> Destination

    var body: some View {
        HStack {
            Text(self.title)
                .font(.title)
            Spacer()
            NavigationLink {
                self.destination()
            } label: {
                Label(self.selectedCategories.joined(separator: ", "), systemImage: "checkmark.square")
            }
        }

        if items.isEmpty {
            Text("Empty Data")
                .font(.title)
                .frame(height: 200)
        } else {
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
        }
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
