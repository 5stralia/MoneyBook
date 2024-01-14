//
//  CategoryStatisticsView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/13/24.
//

import CoreData
import SwiftUI

struct CategoryStatisticsView: View {
    @FetchRequest private var items: FetchedResults<ItemCoreEntity>

    let year: Int
    let month: Int
    let category: String

    internal init(year: Int, month: Int, category: String) {
        let request = NSFetchRequest<ItemCoreEntity>(entityName: "ItemCoreEntity")
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ItemCoreEntity.timestamp,
                ascending: true)
        ]
        request.fetchLimit = 1000

        let startDateComponent = DateComponents(year: year, month: month)
        let startDate = Calendar.current.date(from: startDateComponent)!
        // FIXME: 12월 지난 것 계산 해야 함
        let endDateComponent = DateComponents(year: year, month: month + 1)
        let endDate = Calendar.current.date(from: endDateComponent)!

        request.predicate = NSPredicate(
            format: "category == %@ AND timestamp >= %@ AND timestamp < %@", category, startDate as NSDate,
            endDate as NSDate)
        self._items = FetchRequest(fetchRequest: request)

        self.year = year
        self.month = month
        self.category = category
    }

    var body: some View {
        VStack(spacing: 0) {
            Header(topText: "12월 지출 상제", title: self.category, isHiddenBackButton: false, isEnabledAction: false, action: {})

            ScrollView {
                VStack(spacing: 0) {
                    ChangingGraph()
                        .padding([.top, .bottom], 20)
                        .frame(height: 160)
                        .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))
                    HStack(spacing: 0) {
                        Spacer()
                        Text("지출 합계")
                            .font(.Pretendard(size: 12))
                        Text("1,235,050")
                            .font(.Pretendard(size: 19))
                            .padding(.leading, 46)
                            .padding(.trailing, 28)
                    }
                    .foregroundStyle(Color.dynamicWhite)
                    .padding([.top, .bottom], 30)
                    .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))
                }

                ForEach(Array(self.items).groupedByDate(), id: \.date) { group in
                    TimelineDateView(date: group.date, totalValue: group.totalValue)
                        .padding(.trailing, 20)
                        .padding(.bottom, 5)
                        .padding(.top, 10)

                    ForEach(group.items) { item in
                        TimelineItemView(
                            title: item.title, imageName: "carrot", categoryName: item.category, amount: item.amount
                        )
                        .padding(.leading, 100)
                        .padding(.trailing, 20)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .toolbar(.hidden)
    }

}

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
}

#Preview {
    CategoryStatisticsView(year: 2024, month: 1, category: "식비")
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
