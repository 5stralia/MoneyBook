//
//  TimelineSummaryValueView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/19.
//

import SwiftUI

struct TimelineSummaryValueView: View {
    let paid: Double
    let earning: Double
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, .init(uiColor: .systemBackground)], startPoint: .top, endPoint: .bottom))
            HStack {
                Text(amountFormatter.string(for: paid) ?? "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.indigo)
                    .padding(.leading, 16)
                Spacer()
                Text(amountFormatter.string(for: earning) ?? "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.trailing, 16)
            }
        }
    }
}

struct TimelineSummaryValueView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineSummaryValueView(paid: -700000, earning: 800000)
    }
}
