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

    @State var monthlyCategoryItems: [MonthlyCategoryItem] = [
        .init(ratio: 0.66, title: "식비", value: 759090),
        .init(ratio: 0.13, title: "패션미용", value: 159080),
        .init(ratio: 0.7, title: "반려동물", value: 109345),
        .init(ratio: 0.7, title: "택시비", value: 89300),
        .init(ratio: 0.7, title: "경조사", value: 59590),
        .init(ratio: 0.7, title: "편의점", value: 39040),
        .init(ratio: 0.7, title: "데이트", value: 19080),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Header(topText: "월별 지출", title: "\(self.year).\(self.month)", action: {})

                ScrollView {
                    VStack(spacing: 0) {
                        ChangingGraph()
                            .padding([.top, .bottom], 20)
                            .frame(height: 160)
                            .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))
                        MonthlySummaryView()
                            .frame(height: 240)
                            .padding([.leading, .trailing], 20)
                            .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))

                        ForEach(self.monthlyCategoryItems) { item in
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
                                Text(item.title)
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

    //    private func getAllCategories(isIncome: Bool) -> [String] {
    //        let filtered = self.items.filter { item in
    //            if isIncome {
    //                return item.amount >= 0
    //            } else {
    //                return item.amount < 0
    //            }
    //        }
    //
    //        return Dictionary(grouping: filtered, by: { $0.category }).map { $0.key }
    //    }
}

struct MonthlyItem {
    let value: Double
    let color: Color
}
struct MonthlySummaryView: View {
    @State var items: [Double] = [614050, 410050, 1_234_050, 535050, 635050]

    var body: some View {
        HStack {
            Chart {
                ForEach(
                    self.items.sorted(using: KeyPathComparator(\.self, order: .reverse)).enumerated().map({
                        MonthlyItem(value: $1, color: Color.brownColors[$0])
                    }), id: \.color
                ) { item in
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
    let topText: String
    let title: String
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(self.topText)
                    .font(.Pretendard(size: 12))
                Button(
                    action: self.action,
                    label: {
                        HStack {
                            Text(self.title)
                                .font(.Pretendard(size: 23))
                            Image(systemName: "chevron.down")
                        }
                    })
            }
            Spacer()
        }
        .padding(.bottom, 11)
        .padding(.top, 20)
        .background(Color(red: 255 / 255, green: 195 / 255, blue: 117 / 255))
        .foregroundStyle(Color.dynamicWhite)
    }
}

struct DateEntity: Identifiable {
    let text: String
    let value: Int
    let color: Color

    let id = UUID()
}
struct ChangingGraph: View {
    static let itemCount = 5

    var dateEntities: [DateEntity] = [
        .init(text: "10", value: 614050, color: Color.dynamicWhite.opacity(0.5)),
        .init(text: "11", value: 410050, color: Color.dynamicWhite.opacity(0.5)),
        .init(text: "12", value: 1_234_050, color: Color.dynamicWhite),
        .init(text: "1", value: 0, color: Color.dynamicWhite.opacity(0.5)),
        .init(text: "2", value: 0, color: Color.dynamicWhite.opacity(0.5)),
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
                    .foregroundStyle(entity.color)
                }
            }
            .foregroundStyle(Color.dynamicWhite.opacity(0.5))

            if let maxValue = self.dateEntities.map(\.value).max(),
                let minValue = self.dateEntities.map(\.value).min()
            {
                GeometryReader { geometry in

                    let range = maxValue - minValue
                    let w = geometry.size.width / CGFloat(ChangingGraph.itemCount)

                    Path { path in
                        for (offset, entity) in dateEntities.enumerated() {
                            let x = (CGFloat(offset) + 0.5) * w
                            let y =
                                (geometry.size.height - 20)
                                * (1 - ((CGFloat(entity.value) - CGFloat(minValue)) / CGFloat(range))) + 10

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
                            let y =
                                (geometry.size.height - 20)
                                * (1 - ((CGFloat(entity.value) - CGFloat(minValue)) / CGFloat(range))) + 10

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
