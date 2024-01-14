//
//  ChartView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/08/10.
//

import Charts
import Foundation
import SwiftUI

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
            }
        }
        .onAppear(perform: {
            let date = Date()
            self.year = date.getYear()
            self.month = date.getMonth()
        })
    }

    private func groupedByCategory(items: [ItemCoreEntity], isExpense: Bool) -> [MonthlyCategoryItem] {
        let items = items.filter { isExpense ? ($0.amount >= 0) : ($0.amount <= 0) }
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
                ratio: Float(categorySum / sum), title: category, value: categorySum, color: color)
        }
    }

    //    private func getTopExpenseCategory(items: [ItemCoreEntity], year: Int, month: Int) -> MonthlySummaryItem {
    //        let targetItems = items.filter { $0.timestamp.getYear() == year && $0.timestamp.getMonth() == month }
    //
    //    }
}
struct MonthlySummaryItem {
    let category: String
    let changing: Float
    let color: Color
}

struct MonthlySummaryView: View {
    let monthlyCategoryItems: [MonthlyCategoryItem]

    var body: some View {
        HStack {
            Chart {
                ForEach(self.monthlyCategoryItems.sorted(using: KeyPathComparator(\.value, order: .reverse))) { item in
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

            Spacer(minLength: 15)

            VStack(alignment: .leading) {
                Image("star")
                    .frame(width: 89, height: 37)

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
                    Text(1_235_050.formatted())
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
    let color: Color

    let id = UUID()
}
extension MonthlyCategoryItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
struct MonthlyCategoryItemView: View {
    let item: MonthlyCategoryItem

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(self.item.color)
                .overlay {
                    HStack(spacing: 1) {
                        Text("\(Int(self.item.ratio * 100))")
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
                .foregroundStyle(Color(uiColor: .systemGray))

            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding([.top, .bottom], 18)
                .foregroundStyle(Color(uiColor: .systemGray))
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

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let topText: String
    let title: String
    var isHiddenBackButton: Bool
    let action: (() -> Void)?

    internal init(topText: String, title: String, isHiddenBackButton: Bool = true, action: (() -> Void)? = nil) {
        self.topText = topText
        self.title = title
        self.isHiddenBackButton = isHiddenBackButton
        self.action = action
    }

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                VStack {
                    Text(self.topText)
                        .font(.Pretendard(size: 12))

                    if let action {
                        Button(
                            action: action,
                            label: {
                                HStack {
                                    Text(self.title)
                                        .font(.Pretendard(size: 23))
                                    Image(systemName: "chevron.down")
                                }
                            })
                    } else {
                        Text(self.title)
                            .font(.Pretendard(size: 23))
                    }
                }
                Spacer()
            }

            if !self.isHiddenBackButton {
                HStack {
                    Button(
                        action: {
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        label: {
                            Text("Back")
                                .padding(.leading, 16)
                        })

                    Spacer()
                }
            }
        }
        .padding(.bottom, 11)
        .padding(.top, 20)
        .background(Color(red: 255 / 255, green: 195 / 255, blue: 117 / 255))
        .foregroundStyle(Color.dynamicWhite)
    }
}

struct DateEntity: Identifiable {
    let text: String
    let value: Double?
    let color: Color

    let id = UUID()
}
struct ChangingGraph: View {
    static let itemCount = 5

    let items: [DateEntity]

    init(items: [DateEntity]) {
        if items.count > ChangingGraph.itemCount {
            MyLogger.logger.warning(
                "ChangingGraph.items는 최대 \(ChangingGraph.itemCount)개까지 설정 가능. items.count: \(items.count)"
            )
            self.items = Array(items.prefix(5))
        } else {
            self.items = items
        }
    }

    var body: some View {
        VStack {
            EqualSizeHStack {
                ForEach(self.items) { entity in
                    VStack {
                        Text(entity.text)
                            .font(.Pretendard(size: 10))
                        Text(entity.value?.formatted() ?? "-")
                            .font(.Pretendard(size: 12))
                    }
                    .foregroundStyle(entity.color)
                }
            }
            .foregroundStyle(Color.dynamicWhite.opacity(0.5))

            if self.items.contains(where: { $0.value != nil }),
                let maxValue = self.items.compactMap(\.value).max(),
                let minValue = self.items.compactMap(\.value).min()
            {
                GeometryReader { geometry in

                    let range = maxValue - minValue
                    let w = geometry.size.width / CGFloat(ChangingGraph.itemCount)

                    Path { path in
                        for (offset, entity) in items.enumerated() {
                            guard let value = entity.value else { return }

                            if minValue == maxValue {
                                let x = (CGFloat(offset) + 0.5) * w
                                let y = (geometry.size.height - 20) * 0.5

                                if offset == 2 {
                                    path.addEllipse(in: CGRect(x: x - 5, y: y - 5, width: 10, height: 10))
                                } else {
                                    path.addEllipse(in: CGRect(x: x - 3, y: y - 3, width: 6, height: 6))
                                }

                                continue
                            }

                            let x = (CGFloat(offset) + 0.5) * w
                            let y =
                                (geometry.size.height - 20)
                                * (1 - ((CGFloat(value) - CGFloat(minValue)) / CGFloat(range))) + 10

                            if offset == 2 {
                                path.addEllipse(in: CGRect(x: x - 5, y: y - 5, width: 10, height: 10))
                            } else {
                                path.addEllipse(in: CGRect(x: x - 3, y: y - 3, width: 6, height: 6))
                            }
                        }

                    }

                    Path { path in
                        for (offset, entity) in items.enumerated() {
                            guard let value = entity.value else { return }

                            if minValue == maxValue {
                                let x = (CGFloat(offset) + 0.5) * w
                                let y = (geometry.size.height - 20) * 0.5

                                if offset == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }

                                continue
                            }

                            let x = (CGFloat(offset) + 0.5) * w
                            let y =
                                (geometry.size.height - 20)
                                * (1 - ((CGFloat(value) - CGFloat(minValue)) / CGFloat(range))) + 10

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
            } else {
                Spacer()
            }
        }
    }
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
            subView.place(
                at: CGPoint(x: (CGFloat(offset) * subViewWidth) + (subViewWidth / 2), y: bounds.minY + y),
                anchor: .center, proposal: .unspecified)
        }
    }

}

#Preview {
    ChartView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
