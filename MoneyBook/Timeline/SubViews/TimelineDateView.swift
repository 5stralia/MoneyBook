//
//  TimelineDateView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/19.
//

import SwiftUI

private let monthDayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M.d E"
    return formatter
}()

struct TimelineDateView: View {
    let date: Date
    let totalValue: Double?

    internal init(date: Date, totalValue: Double? = nil) {
        self.date = date
        self.totalValue = totalValue
    }

    var body: some View {
        ZStack {
            Text(monthDayFormatter.string(from: date))
                .font(.Pretendard(size: 15))

            if let totalValue,
                let text = abs(totalValue).string(digits: Locale.isKorean ? 0 : 2)
            {
                HStack {
                    Spacer()
                    Text("\(totalValue > 0 ? "+" : "-") \(text)")
                        .font(.Pretendard(size: 15))
                }
            }
        }
        .foregroundColor(Color(uiColor: .systemGray3))
    }
}

#Preview {
    VStack {
        TimelineDateView(date: Date())
        TimelineDateView(date: Date(), totalValue: -154_000_000)
    }
}
