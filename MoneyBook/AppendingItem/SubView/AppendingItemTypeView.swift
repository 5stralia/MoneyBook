//
//  AppendingItemTypeView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/27/24.
//

import SwiftUI

struct AppendingItemTypeToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Capsule()
            .fill(configuration.isOn ? Color.customOrange1.opacity(0.3) : Color.customIndigo1.opacity(0.3))
            .frame(width: 118, height: 32)
            .overlay(alignment: configuration.isOn ? .leading : .trailing) {
                Capsule()
                    .fill(configuration.isOn ? Color.customOrange1 : Color.customIndigo1)
                    .frame(width: 118 / 2, height: 30)
                    .overlay {
                        Text(configuration.isOn ? "Expense" : "Income")
                            .font(.Pretendard(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
            }
            .onTapGesture {
                withAnimation {
                    configuration.isOn.toggle()
                }
            }
    }
}

private struct Test: View {
    @State var isOn: Bool = false

    var body: some View {
        Toggle(
            isOn: $isOn,
            label: {

            }
        )
        .toggleStyle(AppendingItemTypeToggleStyle())
    }
}

#Preview {
    Test()
}
