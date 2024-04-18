//
//  TimelineSummaryView2.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/15/24.
//

import SwiftUI

struct TimelineSummaryView2: View {
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
                TimelineSummaryItemView(title: "합계", value: self.total)
                    .foregroundStyle(Color(uiColor: .systemGray))

                if self.isExpanded {
                    Spacer()
                    TimelineSummaryItemView(title: "수입", value: self.income)
                        .foregroundStyle(Color.customIndigo1)
                    TimelineSummaryItemView(title: "지출", value: self.expense)
                        .foregroundStyle(Color.customOrange1)
                }
            }
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 18)
            .background(Color(uiColor: .systemGray6))
            .clipShape(RoundedCorner())
        }
    }
}

struct TimelineSummaryItemView: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 2) {
            Text(self.title)
                .font(.Pretendard(size: 11, weight: .bold))
            Text(String(stringLiteral: self.value))
                .font(.Pretendard(size: 14, weight: .semiBold))
        }
    }
}

#Preview {
    TimelineSummaryView2(total: "-5,000,000", income: "5,000,000", expense: "10,000,000")
}
