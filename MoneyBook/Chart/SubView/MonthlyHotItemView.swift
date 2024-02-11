//
//  MonthlyHotItemView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/23/24.
//

import SwiftUI

struct MonthlyHotItemView: View {
    let title: String
    let category: String
    let changing: Double
    let color: Color

    var body: some View {
        HStack(alignment: .top) {
            Text(self.title)
                .font(.Pretendard(size: 12, weight: .medium))
                .frame(width: 70, alignment: .leading)
                .padding(.top, 2)
            RoundedCorner(radius: 2)
                .frame(width: 11, height: 11)
                .padding(.top, 3)
                .foregroundStyle(self.color)

            VStack(alignment: .leading) {
                Text(self.category)
                    .font(.Pretendard(size: 15, weight: .bold))
                Text("( \(self.changing >= 0 ? "+" : "") \(Int(self.changing * 100))% )")
                    .font(.Pretendard(size: 10, weight: .medium))
            }

            Spacer()
        }
    }
}

#Preview {
    MonthlyHotItemView(title: "핫하네!!", category: "카테고리", changing: 1.68, color: .brown1)
}
