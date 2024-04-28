//
//  AppendingItemTypeView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/27/24.
//

import SwiftUI

struct AppendingItemTypeView: View {
    @Binding var isPaid: Bool
    let didChangeType: (_ newValue: Bool) -> Void

    var body: some View {
        Capsule()
            .fill(isPaid ? Color.customOrange1.opacity(0.3) : Color.customIndigo1.opacity(0.3))
            .overlay {
                HStack(spacing: 0) {
                    Capsule()
                        .fill(isPaid ? Color.customOrange1 : .clear)
                        .overlay {
                            Button {
                                withAnimation {
                                    self.isPaid = true
                                }
                                didChangeType(true)
                            } label: {
                                Text("Income")
                                    .font(.Pretendard(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    Capsule()
                        .fill(isPaid ? .clear : Color.customIndigo1)
                        .overlay {
                            Button {
                                withAnimation {
                                    self.isPaid = false
                                }
                                didChangeType(false)
                            } label: {
                                Text("Expense")
                                    .font(.Pretendard(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                }
            }
    }
}

#Preview {
    AppendingItemTypeView(isPaid: .constant(true), didChangeType: { _ in })
}
