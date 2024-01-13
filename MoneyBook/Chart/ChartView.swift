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

    @State var monthlyCategoryItems: [MonthlyCategoryItem] = [
        .init(ratio: 0.66, title: "식비", value: 759090),
        .init(ratio: 0.13, title: "패션미용", value: 159080),
        .init(ratio: 0.7, title: "반려동물", value: 109345),
        .init(ratio: 0.7, title: "택시비", value: 89300),
        .init(ratio: 0.7, title: "경조사", value: 59590),
        .init(ratio: 0.7, title: "편의점", value: 39040),
        .init(ratio: 0.7, title: "데이트", value: 19080)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Header(topText: "월별 지출", title: "\(self.year).\(self.month)", action: { })

                ScrollView {
                    VStack(spacing: 0) {
                        ChangingGraph()
                            .padding([.top, .bottom], 20)
                            .frame(height: 160)
                            .background(Color(red: 244/255, green: 169/255, blue: 72/255))
                        MonthlySummaryView()
                            .frame(height: 240)
                            .padding([.leading, .trailing], 20)
                            .background(Color(red: 244/255, green: 169/255, blue: 72/255))

                        ForEach(self.monthlyCategoryItems) { item in
                            MonthlyCategoryItemView(item: item)
                                .frame(height: 46)
                                .padding([.leading, .trailing], 20)
                        }
                    }
                }
            }
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
        .sorted(using: KeyPathComparator(\.value, order: .reverse))
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
            .sorted(using: KeyPathComparator(\.value, order: .reverse))
    }

    private func incomeData(_ items: [ItemCoreEntity], year: Int, month: Int, length: Int)
        -> [ChartData] {
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
        -> [ChartData] {
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

struct MonthlyItem {
    let value: Double
    let color: Color
}
struct MonthlySummaryView: View {
    @State var items: [Double] = [614050, 410050, 1234050, 535050, 635050]

    var body: some View {
        HStack {
            Chart {
                ForEach(self.items.sorted(using: KeyPathComparator(\.self, order: .reverse)).enumerated().map({ MonthlyItem(value: $1, color: Color.brownColors[$0])}), id: \.color) { item in
                    SectorMark(
                        angle: .value("value", item.value),
                        innerRadius: .ratio(0),
                        outerRadius: .ratio(1.0),
                        angularInset: 1
                    )
                    .foregroundStyle(item.color)
                }
            }
            .frame(width: 160, height: 160)

            VStack(alignment: .leading) {
                HStack {
                    Image("star")
                        .frame(width: 89, height: 37)
                    Spacer()
                }

                MonthlyHotItemView(title: "소비요정 1등!", category: "식비", changing: 0, color: .brown1)
                    .frame(height: 34)
                    .padding(.leading, 10)
                MonthlyHotItemView(title: "라이징 스타!", category: "패션미용", changing: 1.58, color: .brown2)
                    .frame(height: 34)
                    .padding(.leading, 10)
                MonthlyHotItemView(title: "명예소방관", category: "데이트", changing: -0.68, color: .brown3)
                    .frame(height: 34)
                    .padding(.leading, 10)

                HStack {
                    Text("지출 합계")
                        .font(.Pretendard(size: 12))
                    Spacer()
                    Text(1235050.formatted())
                        .font(.Pretendard(size: 19))
                }
            }
            .foregroundStyle(Color.dynamicWhite)
        }
    }
}

struct MonthlyCategoryItem: Identifiable {
    let ratio: Float
    let title: String
    let value: Double

    let id = UUID()
}
struct MonthlyCategoryItemView: View {
    let item: MonthlyCategoryItem

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.brownColors[0])
                .overlay {
                    HStack(spacing: 1) {
                        Text("66")
                            .font(.Pretendard(size: 14))
                        Text("%")
                            .font(.Pretendard(size: 10))
                    }
                    .foregroundStyle(Color.white)
                }
                .frame(width: 46, height: 25)

            Text(self.item.title)
                .font(.Pretendard(size: 16))
                .foregroundStyle(Color.customGray1)

            Spacer()

            Text(self.item.value.string(digits: Locale.isKorean ? 0 : 2) ?? "unknown")
        }
    }
}

struct MonthlyHotItemView: View {
    let title: String
    let category: String
    let changing: Double
    let color: Color

    var body: some View {
        HStack(alignment: .top) {
            Text(self.title)
                .font(.Pretendard(size: 12))
                .frame(width: 70, alignment: .leading)
                .padding(.top, 2)
            RoundedCorner(radius: 2)
                .frame(width: 11, height: 11)
                .padding(.top, 3)
                .foregroundStyle(self.color)

            VStack {
                Text(self.category)
                    .font(.Pretendard(size: 15))
                Text("( \(self.changing >= 0 ? "+" : "") \(Int(self.changing * 100))% )")
                    .font(.Pretendard(size: 11))
            }

            Spacer()
        }
    }
}

struct Header: View {
    let topText: String
    let title: String
    let action: () -> Void

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()
                VStack {
                    Text(self.topText)
                        .font(.Pretendard(size: 12))
                    Button(action: self.action, label: {
                        HStack {
                            Text(self.title)
                                .font(.Pretendard(size: 23))
                            Image(systemName: "chevron.down")
                        }
                    })
                }
                Spacer()
            }
        }
        .padding(.bottom, 11)
        .frame(height: 116)
        .background(Color(red: 255/255, green: 195/255, blue: 117/255))
        .foregroundStyle(Color.dynamicWhite)
    }
}

struct DateEntity: Identifiable {
    let text: String
    let value: Int

    let id = UUID()
}
struct ChangingGraph: View {
    static let itemCount = 5

    var dateEntities: [DateEntity] = [
        .init(text: "10", value: 614050),
        .init(text: "11", value: 410050),
        .init(text: "12", value: 1234050),
        .init(text: "1", value: 0),
        .init(text: "2", value: 0)
//        .init(text: "1", value: 535050),
//        .init(text: "2", value: 635050),
    ]

    var body: some View {
        VStack {
            EqualSizeHStack {
                ForEach(self.dateEntities) { entity in
                    VStack {
                        Text(entity.text)
                            .font(.Pretendard(size: 10))
                        Text(entity.value.formatted())
                            .font(.Pretendard(size: 12))
                    }
                }
            }
            .foregroundStyle(Color.dynamicWhite.opacity(0.5))

            if let maxValue = self.dateEntities.map(\.value).max(),
               let minValue = self.dateEntities.map(\.value).min() {
                GeometryReader { geometry in

                    let range = maxValue - minValue
                    let w = geometry.size.width / CGFloat(ChangingGraph.itemCount)

                    Path { path in
                        for (offset, entity) in dateEntities.enumerated() {
                            let x = (CGFloat(offset) + 0.5) * w
                            let y = (geometry.size.height - 20) * (1 - ((CGFloat(entity.value) - CGFloat(minValue)) / CGFloat(range))) + 10

                            if entity.value == maxValue {
                                path.addEllipse(in: CGRect(x: x - 5, y: y - 5, width: 10, height: 10))
                            } else {
                                path.addEllipse(in: CGRect(x: x - 3, y: y - 3, width: 6, height: 6))
                            }
                        }

                    }

                    Path { path in
                        for (offset, entity) in dateEntities.enumerated() {
                            let x = (CGFloat(offset) + 0.5) * w
                            let y = (geometry.size.height - 20) * (1 - ((CGFloat(entity.value) - CGFloat(minValue)) / CGFloat(range))) + 10

                            if offset == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [1.5]))
                }
                .foregroundStyle(Color.dynamicWhite)
            }
        }
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
        .chartLegend(.hidden)
    }
}

private let percentageFomatter: NumberFormatter = {
    let fomatter = NumberFormatter()
    fomatter.numberStyle = .percent
    return fomatter
}()
struct StatisticsMonthlyChart: View {
    fileprivate var items: [ChartData]
    private var sum: Double { self.items.reduce(0, { $0 + $1.value }) }

    var body: some View {
        Chart {
            ForEach(self.items) { item in
                BarMark(
                    x: .value("amount", item.value),
                    y: .value("category", item.category),
                    width: .fixed(20)
                )
                .foregroundStyle(by: .value("category", item.category))
                .annotation(position: .trailing) {
                    let percentage = percentageFomatter.string(from: NSNumber(value: item.value / self.sum))
                    Text(percentage ?? "?")
                }
            }
        }
        .frame(height: 60 * CGFloat(self.items.count))
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
                Image(systemName: "checkmark.square")
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

struct EqualSizeHStack: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let height = subviews.map({ $0.sizeThatFits(.unspecified).height }).max() ?? 0
        let width = proposal.replacingUnspecifiedDimensions().width

        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let subViewWidth = bounds.width / CGFloat(subviews.count)
        let y = bounds.height / 2

        for (offset, subView) in subviews.enumerated() {
            subView.place(at: CGPoint(x: (CGFloat(offset) * subViewWidth) + (subViewWidth / 2), y: bounds.minY + y), anchor: .center, proposal: .unspecified)
        }
    }

}
