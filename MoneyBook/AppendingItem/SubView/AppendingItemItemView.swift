//
//  AppendingItemItemView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/27/24.
//

import SwiftUI

struct AppendingItemItemView<T: View>: View {
    let title: String
    let backgroundColor: Color
    let action: () -> Void
    @ViewBuilder let label: () -> T

    var body: some View {
        Button(
            action: action,
            label: {
                HStack {
                    Text(title)
                        .font(.Pretendard(size: 15, weight: .bold))
                    Spacer()
                    label()
                }
                .padding([.top, .bottom], 13)
                .padding([.leading, .trailing], 20)
                .foregroundStyle(Color.primary)
                .background(backgroundColor)
            })
    }
}

#Preview {
    AppendingItemItemView(title: "name", backgroundColor: .customOrange1, action: {}) {
        Text("hello world")
    }
}
