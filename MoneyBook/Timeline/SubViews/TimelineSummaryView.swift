//
//  TimelineSummaryView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/12.
//

import SwiftUI

struct TimelineSummaryView: View {
    let totalValue: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Color.indigo
                    .frame(width: 300)
                Color.orange
            }
            .frame(height: 5)
            
            HStack {
                Text("합계")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.leading, 16)
                Spacer()
                Text(amountFormatter.string(for: totalValue) ?? "0")
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
        TimelineSummaryView(totalValue: 800000)
            .previewLayout(.sizeThatFits)
    }
}
