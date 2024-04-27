//
//  TimelineSummaryView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/12.
//

import SwiftUI

struct TimelineSummaryColorView: View {
    let paid: Double
    let earning: Double

    var earningMultiplier: Double {
        guard earning > 0 else { return 0 }

        return earning / (paid + earning)
    }

    var body: some View {
        GeometryReader { metrics in
            HStack(spacing: 0) {
                Color.customIndigo1
                    .frame(width: metrics.size.width * earningMultiplier)
                Color.customOrange1
            }
        }
        .frame(height: 5)
    }
}

struct TimelineSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineSummaryColorView(paid: 600000, earning: 800000)
            .previewLayout(.sizeThatFits)
    }
}
