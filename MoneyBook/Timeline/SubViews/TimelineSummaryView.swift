//
//  TimelineSummaryView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/15/24.
//

import SwiftUI

struct TimelineSummaryView: View {
    @State var isExpanded: Bool = false

    let total: String
    let income: String
    let expense: String

    @State private var work: Task<Void, any Error>?

    var body: some View {
        Button {
            withAnimation(.easeOut) {
                self.isExpanded.toggle()
            }

            self.work?.cancel()
            if self.isExpanded {
                self.work = Task {
                    try await Task.sleep(for: .seconds(3))
                    withAnimation(.easeOut) {
                        self.isExpanded = false
                    }
                }
            }
        } label: {
            HStack {
                TimelineSummaryItemView(
                    title: "합계", value: self.total, titleColor: Color(uiColor: .systemGray2), valueColor: .customBlack2)

                if self.isExpanded {
                    Spacer()
                    TimelineSummaryItemView(
                        title: "수입", value: self.income, titleColor: .customIndigo1, valueColor: .customIndigo1)
                    TimelineSummaryItemView(
                        title: "지출", value: self.expense, titleColor: .customOrange1, valueColor: .customOrange1)
                }
            }
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 18)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedCorner())
            .shadow(color: .black.opacity(0.16), radius: 6, y: 3)
        }
    }
}

struct TimelineSummaryItemView: View {
    let title: String
    let value: String
    let titleColor: Color
    let valueColor: Color

    init(title: String, value: String, titleColor: Color = .primary, valueColor: Color = .primary) {
        self.title = title
        self.value = value
        self.titleColor = titleColor
        self.valueColor = valueColor
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(self.title)
                .font(.Pretendard(size: 11, weight: .bold))
                .foregroundStyle(titleColor)
            Text(String(stringLiteral: self.value))
                .font(.Pretendard(size: 14, weight: .semiBold))
                .foregroundStyle(valueColor)
        }
    }
}

#Preview {
    TimelineSummaryView(total: "-5,000,000", income: "5,000,000", expense: "10,000,000")
}
