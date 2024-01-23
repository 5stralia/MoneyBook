//
//  EqualSizeHStack.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/23/24.
//

import SwiftUI

struct EqualSizeHStack: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let height = subviews.map({ $0.sizeThatFits(.unspecified).height }).max() ?? 0
        let width = proposal.replacingUnspecifiedDimensions().width

        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let subViewWidth = bounds.width / CGFloat(subviews.count)
        let y = bounds.height / 2

        for (offset, subView) in subviews.enumerated() {
            subView.place(
                at: CGPoint(x: (CGFloat(offset) * subViewWidth) + (subViewWidth / 2), y: bounds.minY + y),
                anchor: .center, proposal: .unspecified)
        }
    }

}
