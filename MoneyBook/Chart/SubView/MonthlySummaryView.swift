//
//  MonthlySummaryView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/23/24.
//

import Charts
import SwiftUI

struct MonthlySummaryItem {
    let category: String
    let changing: Float
    let color: Color
}

struct MonthlySummaryViewChartItem: Identifiable {
    let title: String
    let value: Double
    let color: Color

    let id = UUID()
}
extension MonthlySummaryViewChartItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}

struct MonthlySummaryView: View {
    let prevMonthlyCategorySummary: [String: Double]
    let monthlyCategoryItems: [MonthlySummaryViewChartItem]

    private var maxExpense: (category: String, changing: Double) {
        let maxValue = self.monthlyCategoryItems.map(\.value).max() ?? 0
        let maxCategory = self.monthlyCategoryItems.first(where: { $0.value == maxValue })!

        let changing = self.prevMonthlyCategorySummary[maxCategory.title].map({ maxCategory.value / $0 }) ?? 0

        return (category: maxCategory.title, changing: changing)
    }

    private var total: Double {
        self.monthlyCategoryItems.map(\.value).reduce(0, +)
    }

    var body: some View {
        HStack {
            Chart {
                ForEach(self.monthlyCategoryItems) { item in
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

                let maxExpenseItem = self.maxExpense
                MonthlyHotItemView(
                    title: "소비요정 1등!",
                    category: maxExpenseItem.category,
                    changing: maxExpenseItem.changing,
                    color: .brown1
                )
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
                    Text(self.total.formatted())
                        .font(.Pretendard(size: 19))
                }
            }
            .foregroundStyle(Color.dynamicWhite)
        }
    }
}

#Preview {
    Group {
        MonthlySummaryView(
            prevMonthlyCategorySummary: [:],
            monthlyCategoryItems: [
                .init(title: "식비", value: 6_000_000, color: .brown1),
                .init(title: "교통비", value: 2_500_000, color: .brown2),
                .init(title: "기타", value: 1_500_000, color: .brown3),
                .init(title: "1", value: 500_000, color: .brown3),
                .init(title: "2", value: 500_000, color: .brown3),
                .init(title: "3", value: 500_000, color: .brown3),
                .init(title: "4", value: 500_000, color: .brown3),
            ]
        )
        .frame(height: 240)
        .padding([.leading, .trailing], 20)
        .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))

        MonthlySummaryView(
            prevMonthlyCategorySummary: [:],
            monthlyCategoryItems: [
                .init(title: "식비", value: 6_000_000, color: .brown1),
                .init(title: "쇼핑", value: 7_000_000, color: .brown2),
            ]
        )
        .frame(height: 240)
        .padding([.leading, .trailing], 20)
        .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))

        MonthlySummaryView(
            prevMonthlyCategorySummary: ["쇼핑": 1_000_000],
            monthlyCategoryItems: [
                .init(title: "식비", value: 6_000_000, color: .brown1),
                .init(title: "쇼핑", value: 7_000_000, color: .brown2),
            ]
        )
        .frame(height: 240)
        .padding([.leading, .trailing], 20)
        .background(Color(red: 244 / 255, green: 169 / 255, blue: 72 / 255))
    }
}
