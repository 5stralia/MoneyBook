//
//  TimelineSummaryView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/12.
//

import SwiftUI

struct TimelineSummaryView: View {
    let paid: Int
    let earning: Int
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, .init(uiColor: .systemBackground)], startPoint: .top, endPoint: .bottom))
                VStack(spacing: 0) {
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
                    HStack(spacing: 0) {
                        Color.indigo
                            .frame(width: 300)
                        Color.orange
                    }
                    .frame(height: 5)
                }
            }
            HStack {
                Text("합계")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.leading, 16)
                Spacer()
                Text(amountFormatter.string(for: earning + paid) ?? "0")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.trailing, 16)
            }
            .frame(height: 32)
            .background(Color(uiColor: .systemGray2))
            .foregroundColor(.white)
        }
    }
}

struct TimelineSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineSummaryView(paid: -770000, earning: 800000)
//            .previewLayout(.sizeThatFits)
            .previewLayout(.fixed(width: 450, height: 69))
    }
}
