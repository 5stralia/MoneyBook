//
//  MonthlyCategoryItemView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/23/24.
//

import SwiftUI

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
                            .font(.Pretendard(size: 13, weight: .bold))
                        Text("%")
                            .font(.Pretendard(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Color.white)
                }
                .frame(width: 46, height: 25)

            Text(self.item.title)
                .font(.Pretendard(size: 16, weight: .bold))
                .foregroundStyle(Color.customGray1)

            Spacer()

            Text(self.item.value.string(digits: Locale.isKorean ? 0 : 2) ?? "unknown")
                .font(.Pretendard(size: 14, weight: .medium))
                .foregroundStyle(Color(uiColor: .systemGray))

            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding([.top, .bottom], 18)
                .foregroundStyle(Color(uiColor: .systemGray))
        }
    }
}

#Preview {
    MonthlyCategoryItemView(item: .init(ratio: 0.4, title: "카테고리", value: 500000, color: .brown1))
        .frame(height: 44)
}
