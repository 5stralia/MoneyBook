//
//  AppendingItemTypeView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/27/24.
//

import SwiftUI

struct AppendingItemTypeView: View {
    @Binding var isExpense: Bool
    let didChangeType: (_ newValue: Bool) -> Void

    var body: some View {
        Capsule()
            .fill(isExpense ? Color.customOrange1.opacity(0.3) : Color.customIndigo1.opacity(0.3))
            .overlay {
                HStack(spacing: 0) {
                    Capsule()
                        .fill(isExpense ? Color.customOrange1 : .clear)
                        .overlay {
                            Button {
                                withAnimation {
                                    self.isExpense = true
                                }
                                didChangeType(true)
                            } label: {
                                Text("Expense")
                                    .font(.Pretendard(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    Capsule()
                        .fill(isExpense ? .clear : Color.customIndigo1)
                        .overlay {
                            Button {
                                withAnimation {
                                    self.isExpense = false
                                }
                                didChangeType(false)
                            } label: {
                                Text("Income")
                                    .font(.Pretendard(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                }
            }
    }
}

#Preview {
    AppendingItemTypeView(isExpense: .constant(true), didChangeType: { _ in })
}
