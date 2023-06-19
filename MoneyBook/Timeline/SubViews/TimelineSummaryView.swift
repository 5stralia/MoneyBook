//
//  TimelineSummaryView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/12.
//

import SwiftUI

struct TimelineSummaryView: View {
    let paid: Double
    let earning: Double
    
    var earningMultiplier: Double {
        guard earning > 0 else { return 0 }
        
        return earning / (-paid + earning)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { metrics in
                HStack(spacing: 0) {
                    Color.indigo
                    Color.orange
                        .frame(width: metrics.size.width * earningMultiplier)
                }
            }
            .frame(height: 5)
            
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
        TimelineSummaryView(paid: -600000, earning: 800000)
            .previewLayout(.sizeThatFits)
    }
}
