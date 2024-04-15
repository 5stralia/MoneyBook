//
//  TimelineItemView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/11.
//

import SwiftUI

struct TimelineItemView: View {
    let title: String
    let categoryName: String
    let amount: Double
    let isExpense: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Spacer()
                Text(self.title)
                    .font(.Pretendard(size: 16, weight: .bold))
                HStack {
                    Text(self.categoryName)
                        .font(.Pretendard(size: 12, weight: .medium))
                    Spacer()
                    HStack {
                        Text(self.isExpense ? "- " : "+ ")
                            .font(.Pretendard(size: 16, weight: .bold))
                        Text(self.amount.formatted())
                            .font(.Pretendard(size: 16, weight: .bold))
                    }
                }
                Spacer()
            }
        }
        .padding([.leading, .trailing], 12)
        .background(self.isExpense ? Color.orange : Color.indigo)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .foregroundColor(.dynamicWhite)
    }
}

public let amountFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.positivePrefix = "+ "
    formatter.negativePrefix = "- "
    return formatter
}()

struct TimelineItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimelineItemView(title: "신미방 마라탕", categoryName: "식비", amount: 32000, isExpense: true)
                .previewLayout(
                    .fixed(
                        width: /*@START_MENU_TOKEN@*/ 250.0 /*@END_MENU_TOKEN@*/,
                        height: /*@START_MENU_TOKEN@*/ 80.0 /*@END_MENU_TOKEN@*/))
            TimelineItemView(title: "돈 주움", categoryName: "식비", amount: 32000, isExpense: false)
                .previewLayout(
                    .fixed(
                        width: /*@START_MENU_TOKEN@*/ 250.0 /*@END_MENU_TOKEN@*/,
                        height: /*@START_MENU_TOKEN@*/ 80.0 /*@END_MENU_TOKEN@*/))
        }
    }
}
