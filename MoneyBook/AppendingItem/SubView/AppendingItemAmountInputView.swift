//
//  AppendingItemAmountInputView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/27/24.
//

import SwiftUI

enum AppendingItemAmountInputOperation {
    case divide
    case multiplier
    case add
    case subtraction
}

struct AppendingItemAmountInputView: View {
    @Binding var value: Double
    @State private var operation: AppendingItemAmountInputOperation?
    @State private var isFloating: Bool = false
    @State private var prevValue = Value()
    @State private var currentValue: Value
    @Binding var isExpense: Bool

    init(value: Binding<Double>, isExpense: Binding<Bool>) {
        self._value = value
        self._isExpense = isExpense

        var value = value.wrappedValue
        var floatingPoint = 1.0

        while (value - value.rounded(.towardZero)) > 0 {
            value *= 10
            floatingPoint *= 10
        }

        self.currentValue = Value(original: value, floating: floatingPoint)
    }

    var body: some View {
        GeometryReader { reader in
            VStack(alignment: .trailing, spacing: 0) {
                Text(currentValue.formatted)
                    .font(.Pretendard(size: 18, weight: .bold))
                    .foregroundStyle(Color(uiColor: .systemBackground))
                    .padding([.top, .bottom], 22)
                    .padding(.trailing, 10)

                let spacing: CGFloat = 3
                let rows: CGFloat = 5
                let length = (reader.size.width - (spacing * (rows - 1))) / rows
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        AppendingItemAmountInputButton(
                            action: { calculate(.remove) }, text: "->", isNumber: false, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.number(7)) }, text: "7", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.number(8)) }, text: "8", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.number(9)) }, text: "9", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.divide) }, text: "/", isNumber: false, length: length)
                    }
                    HStack(spacing: spacing) {
                        AppendingItemAmountInputButton(
                            action: { calculate(.clear) }, text: "AC", isNumber: false, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.number(4)) }, text: "4", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.number(5)) }, text: "5", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.number(6)) }, text: "6", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.multiplier) }, text: "X", isNumber: false, length: length)
                    }
                    HStack(spacing: spacing) {
                        Color.clear
                        AppendingItemAmountInputButton(
                            action: { calculate(.number(1)) }, text: "1", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.number(2)) }, text: "2", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.number(3)) }, text: "3", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.subtraction) }, text: "-", isNumber: false, length: length)
                    }
                    HStack(spacing: spacing) {
                        AppendingItemAmountInputButton(
                            action: { calculate(.number(0)) }, text: "0", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.doubleZero) }, text: "00", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.point) }, text: ".", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.result) }, text: "=", isNumber: false, length: length)
                        AppendingItemAmountInputButton(
                            action: { calculate(.add) }, text: "+", isNumber: false, length: length)
                    }
                }

                Spacer()
                    .frame(maxHeight: .infinity)
            }
        }
        .padding([.leading, .bottom, .trailing], 30)
        .background(isExpense ? Color.customOrange1 : Color.customIndigo1)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
    }

    struct Value {
        var original: Double
        var floating: Double

        var value: Double {
            original / floating
        }

        var formatted: String {
            value.formatted(.number.grouping(.never))
        }

        init() {
            self.original = 0
            self.floating = 1
        }

        init(original: Double, floating: Double) {
            self.original = original
            self.floating = floating
        }

        static func + (lhs: Value, rhs: Value) -> Value {
            let maxFloating = max(lhs.floating, rhs.floating)

            let lValue = lhs.original * (maxFloating / lhs.floating)
            let rValue = rhs.original * (maxFloating / rhs.floating)

            return Value(original: lValue + rValue, floating: maxFloating)
        }

        static func - (lhs: Value, rhs: Value) -> Value {
            let maxFloating = max(lhs.floating, rhs.floating)

            let lValue = lhs.original * (maxFloating / lhs.floating)
            let rValue = rhs.original * (maxFloating / rhs.floating)

            return Value(original: lValue - rValue, floating: maxFloating)
        }

        static func * (lhs: Value, rhs: Value) -> Value {
            return Value(original: lhs.original * rhs.original, floating: lhs.floating * rhs.floating)
        }

        static func / (lhs: Value, rhs: Value) -> Value {
            return Value(original: lhs.original / rhs.original, floating: lhs.floating / rhs.floating)
        }
    }

    enum CalculatorInput {
        case number(Int)
        case doubleZero
        case divide
        case multiplier
        case add
        case subtraction
        case point
        case clear
        case remove
        case result
    }
    private func calculate(_ input: CalculatorInput) {
        switch input {
        case .number(let int):
            if isFloating {
                currentValue.floating *= 10
            }
            currentValue.original = currentValue.original * 10 + Double(int)
            if operation == nil {
                value = currentValue.value
            }
        case .doubleZero:
            currentValue.original = currentValue.original * 100
            value = currentValue.value
        case .divide:
            calculate()
            prevValue = currentValue
            operation = .divide
            currentValue = Value()
            value = prevValue.value
        case .multiplier:
            calculate()
            prevValue = currentValue
            operation = .multiplier
            currentValue = Value()
            value = prevValue.value
        case .add:
            calculate()
            prevValue = currentValue
            operation = .add
            currentValue = Value()
            value = prevValue.value
        case .subtraction:
            calculate()
            prevValue = currentValue
            operation = .subtraction
            currentValue = Value()
            value = prevValue.value
        case .point:
            guard !isFloating else { break }

            isFloating = true
            value = currentValue.value
        case .clear:
            prevValue = Value()
            operation = nil
            currentValue = Value()
            isFloating = false
            value = currentValue.value
        case .remove:
            if currentValue.floating > 1 {
                currentValue.original = Double(Int(currentValue.original / 10))
                currentValue.floating /= 10
            } else {
                currentValue.original = Double(Int(currentValue.original / 10))
            }
            value = currentValue.value
        case .result:
            calculate()
            value = currentValue.value
        }
    }

    private func calculate() {
        isFloating = false
        guard let operation else { return }

        switch operation {
        case .divide:
            currentValue = prevValue / currentValue
        case .multiplier:
            currentValue = prevValue * currentValue
        case .add:
            currentValue = prevValue + currentValue
        case .subtraction:
            currentValue = prevValue - currentValue
        }

        self.operation = nil
    }
}

struct AppendingItemAmountInputButton: View {
    let action: () -> Void
    let text: String
    let isNumber: Bool
    let length: CGFloat

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.Pretendard(size: 17, weight: .bold))
                .foregroundStyle(Color(uiColor: .systemBackground))
                .frame(width: length, height: length)
                .background(
                    isNumber
                        ? Color(uiColor: .systemBackground).opacity(0.24)
                        : Color.black.opacity(0.1)
                )
                .clipShape(Circle())
        }
    }

    init(action: @escaping () -> Void, text: String, isNumber: Bool, length: CGFloat) {
        self.action = action
        self.text = text
        self.isNumber = isNumber
        self.length = length
    }
}

#Preview {
    AppendingItemAmountInputView(value: .constant(0), isExpense: .constant(true))
}
