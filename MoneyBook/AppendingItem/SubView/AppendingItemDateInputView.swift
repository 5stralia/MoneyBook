//
//  AppendingItemDateInputView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/27/24.
//

import SwiftUI

struct AppendingItemDateInputView: View {
    @Binding var isExpense: Bool
    @Binding var selected: Date

    var body: some View {
        ZStack(alignment: .center) {
            (isExpense ? Color.customOrange1 : Color.customIndigo1)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))

            DatePicker("", selection: $selected, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.wheel)
                .background((isExpense ? Color.customOrange1 : Color.customIndigo1).colorInvert())
                .tint(Color.black)
                .colorMultiply(Color.white)
                .colorInvert()
                .padding([.leading, .trailing], 20)

        }
    }
}
#Preview {
    AppendingItemDateInputView(isExpense: .constant(false), selected: .constant(Date()))
}
