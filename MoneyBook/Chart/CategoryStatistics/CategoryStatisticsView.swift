//
//  CategoryStatisticsView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/13/24.
//

import SwiftData
import SwiftUI

struct CategoryStatisticsView: View {
    @Environment(\.modelContext) var modelContext

    @State private var items: [ItemCoreEntity] = []

    let year: Int
    let month: Int
    let category: String

    private var isExpense: Bool {
        return self.items.first?.category?.isExpense ?? true
    }

    internal init(year: Int, month: Int, category: String) {
        //        let request = NSFetchRequest<ItemCoreEntity>(entityName: "ItemCoreEntity")
        //        request.sortDescriptors = [
        //            NSSortDescriptor(
        //                keyPath: \ItemCoreEntity.timestamp,
        //                ascending: true)
        //        ]
        //        request.fetchLimit = 1000
        //
        //
        //        request.predicate = NSPredicate(
        //            format: "category == %@ AND timestamp >= %@ AND timestamp < %@", category, startDate as NSDate,
        //            endDate as NSDate)
        //        self._items = FetchRequest(fetchRequest: request)

        self.year = year
        self.month = month
        self.category = category
    }

    var body: some View {
        VStack(spacing: 0) {
            Header(
                topText: "\(self.month)월 지출 상세",
                title: self.category,
                isHiddenBackButton: false
            )

            ScrollView {
                VStack(spacing: 0) {
                    ChangingGraph(
                        items: Array(self.items).statisticsByMonth(targetYear: self.year, targetMonth: self.month)
                    )
                    .padding([.top, .bottom], 20)
                    .frame(height: 160)
                    .background(Color.backgroundColor(isExpense: self.isExpense))
                    HStack(spacing: 0) {
                        Spacer()
                        Text("Total")
                            .font(.Pretendard(size: 12, weight: .bold))
                        Text(Array(self.items).totalValue(year: self.year, month: self.month).formatted())
                            .font(.Pretendard(size: 19, weight: .semiBold))
                            .padding(.leading, 46)
                            .padding(.trailing, 28)
                    }
                    .foregroundStyle(Color.dynamicWhite)
                    .padding([.top, .bottom], 30)
                    .background(Color.backgroundColor(isExpense: self.isExpense))
                }

                let currentItems = Array(
                    self.items.filter({ $0.timestamp.getYear() == self.year && $0.timestamp.getMonth() == self.month }))
                ForEach(Array(currentItems).groupedByDate(), id: \.date) { group in
                    TimelineDateView(date: group.date, totalValue: group.totalValue)
                        .padding(.trailing, 20)
                        .padding(.bottom, 5)
                        .padding(.top, 10)

                    ForEach(group.items) { item in
                        TimelineItemView(
                            title: item.title, categoryName: item.category?.title ?? "",
                            amount: item.amount, isExpense: item.category?.isExpense ?? true
                        )
                        .padding(.leading, 100)
                        .padding(.trailing, 20)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .toolbar(.hidden)
        .onAppear {
            let currentDateComponents = DateComponents(year: year, month: month)
            let current = Calendar.current.date(from: currentDateComponents)!
            let startDate = Calendar.current.date(byAdding: .month, value: -2, to: current)!
            let endDate = Calendar.current.date(byAdding: .month, value: 2, to: current)!

            let descriptor = FetchDescriptor<ItemCoreEntity>(
                predicate: #Predicate {
                    $0.category?.title == category && $0.timestamp >= startDate && $0.timestamp < endDate
                },
                sortBy: [SortDescriptor<ItemCoreEntity>(\.timestamp)]
            )

            do {
                let request = try modelContext.fetch(descriptor)
                self.items = request
            } catch let error {
                MyLogger.error("\(error)")
            }
        }
    }

}

private let yearMonthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.M"
    return formatter
}()
struct ItemGroupByDate {
    let date: Date
    let totalValue: Double
    let items: [ItemCoreEntity]
}
extension Array where Element == ItemCoreEntity {
    func groupedByDate() -> [ItemGroupByDate] {
        let dict = Dictionary(grouping: self) { item in
            let comp = DateComponents(
                year: item.timestamp.getYear(), month: item.timestamp.getMonth(), day: item.timestamp.getDay())
            return Calendar.current.date(from: comp)!
        }

        return dict.map({ (date, items) in
            ItemGroupByDate(date: date, totalValue: items.map(\.amount).reduce(0, +), items: items)
        })
        .sorted(using: KeyPathComparator(\.date))
    }

    func statisticsByMonth(targetYear: Int, targetMonth: Int) -> [DateEntity] {
        guard let targetDate = Calendar.current.date(from: DateComponents(year: targetYear, month: targetMonth)) else {
            return []
        }

        let months = (-2...2).compactMap { i in
            Calendar.current.date(byAdding: .month, value: i, to: targetDate)
        }
        var values: [Double?] = [Double?](repeating: nil, count: ChangingGraph.itemCount)

        for item in self {
            guard
                let index = months.firstIndex(where: { date in
                    date.getYear() == item.timestamp.getYear() && date.getMonth() == item.timestamp.getMonth()
                })
            else { continue }

            if values[index] == nil {
                values[index] = item.amount
            } else {
                values[index]! += item.amount
            }
        }

        return zip(months, values).map { (month, value) in
            let color =
                if month.getYear() == targetYear && month.getMonth() == targetMonth {
                    Color.dynamicWhite
                } else {
                    Color.dynamicWhite.opacity(0.5)
                }
            return DateEntity(text: yearMonthFormatter.string(from: month), value: value, color: color)
        }
    }

    func totalValue(year: Int, month: Int) -> Double {
        self.filter { $0.timestamp.getYear() == year && $0.timestamp.getMonth() == month }
            .map(\.amount)
            .reduce(0, +)
    }
}

#Preview {
    CategoryStatisticsView(year: 2024, month: 1, category: "식비")
        .modelContainer(PersistenceController.preview.container)
}
