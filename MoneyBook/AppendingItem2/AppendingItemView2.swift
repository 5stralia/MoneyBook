//
//  AppendingItemView2.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/16/24.
//

import SwiftUI

struct AppendingItemView2: View {
    @State var isExpense: Bool = true
    @State var amount: Double = 0

    @State var inputType: AppendingInputType?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Header(topText: "", title: "append", isHiddenBackButton: false)

                AppendingContentsView(isExpense: $isExpense, inputType: $inputType)
                    .padding([.top, .leading, .trailing], 20)
                    .padding(.bottom, 0)

                Spacer()

                Button {
                    // TODO: 저장!
                } label: {
                    Text("OK")
                        .foregroundStyle(Color.white)
                }
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .background(isExpense ? Color.customOrange1 : Color.customIndigo1)
                .clipShape(RoundedCorner(radius: 15, corners: [.topLeft, .topRight]))

            }

            if inputType == .date {

            } else if inputType == .category {

            } else if inputType == .amount {
                AppendingItemAmountInputView(value: $amount)
                    .frame(height: 400)
            }
        }
    }
}

enum AppendingInputType: Hashable {
    case date
    case category
    case amount
    case title
    case note
}

struct AppendingContentsView: View {
    @Binding var isExpense: Bool
    @State var title: String = ""
    @State var note: String = ""

    @Binding var inputType: AppendingInputType?
    @FocusState var focused: AppendingInputType?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    Spacer()
                    AppendingItemTypeView2(isPaid: $isExpense)
                        .frame(width: 118, height: 32)
                }
                .padding(.bottom, 8)

                VStack(spacing: 0) {
                    AppendingItemItemView(
                        title: "날짜",
                        backgroundColor: backgroundColor(.date),
                        action: { select(.date) },
                        label: {
                            Text("2024.02.19")
                                .font(.Pretendard(size: 18, weight: .bold))
                            Text("화")
                                .font(.Pretendard(size: 12, weight: .bold))
                        }
                    )
                    AppendingItemItemView(
                        title: "분류",
                        backgroundColor: backgroundColor(.category),
                        action: { select(.category) },
                        label: {
                            Text("반려동물")
                                .font(.Pretendard(size: 15, weight: .bold))
                        }
                    )
                    AppendingItemItemView(
                        title: "금액",
                        backgroundColor: backgroundColor(.amount),
                        action: { select(.amount) },
                        label: {
                            Text("1,469,800")
                                .font(.Pretendard(size: 15, weight: .bold))
                        }
                    )
                    AppendingItemItemView(
                        title: "이름",
                        backgroundColor: backgroundColor(.title),
                        action: { select(.title) },
                        label: {
                            TextField("", text: $title)
                                .font(.Pretendard(size: 15, weight: .bold))
                                .multilineTextAlignment(.trailing)
                                .focused($focused, equals: .title)
                                .onSubmit { select(nil) }
                        }
                    )
                }
                .clipShape(RoundedCorner(radius: 11))
                .padding(.bottom, 17)

                Button(
                    action: {
                        select(.note)
                    },
                    label: {
                        VStack(alignment: .leading) {
                            Text("메모")
                                .font(.Pretendard(size: 15, weight: .bold))
                            TextField("", text: $note, axis: .vertical)
                                .font(.Pretendard(size: 15, weight: .regular))
                                .multilineTextAlignment(.leading)
                                .focused($focused, equals: .note)
                                .onSubmit { select(nil) }
                        }
                        .padding([.top, .bottom], 13)
                        .padding([.leading, .trailing], 20)
                        .foregroundStyle(Color.primary)
                        .background(Color.gray.opacity(inputType == .note ? 0.15 : 0.05))
                        .clipShape(RoundedCorner(radius: 11))
                    })
            }
        }
        .tint(isExpense ? Color.customOrange1 : Color.customIndigo1)
    }

    func select(_ type: AppendingInputType?) {
        if inputType == type {
            inputType = nil
        } else {
            inputType = type
        }

        focused = inputType
    }

    func backgroundColor(_ type: AppendingInputType?) -> Color {
        let opacity = inputType == type ? 0.3 : 0.1
        let color = isExpense ? Color.customOrange1 : Color.customIndigo1

        return color.opacity(opacity)
    }
}

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

struct AppendingItemTypeView2: View {
    @Binding var isPaid: Bool

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
                            } label: {
                                Text("지출")
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
                            } label: {
                                Text("소득")
                                    .font(.Pretendard(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                }
            }
    }
}

enum AppendingItemAmountInputOperation {
    case divide
    case multiplier
    case add
    case subtraction
    case point
}

struct AppendingItemAmountInputView: View {
    @Binding var value: Double
    @State private var operation: AppendingItemAmountInputOperation?
    @State private var prevValue: Double = 0

    var body: some View {
        VStack(alignment: .trailing) {
            Text(value.formatted())
                .font(.Pretendard(size: 18, weight: .bold))
                .foregroundStyle(Color(uiColor: .systemBackground))
                .padding([.top, .bottom], 22)

            GeometryReader { reader in
                let length = Int((reader.size.width - (3 * 4)) / 5)
                VStack {
                    HStack(spacing: 3) {
                        AppendingItemAmountInputButton(
                            action: { value = Double(Int(value / 10)) }, text: "->", isNumber: false, length: length)
                        AppendingItemAmountInputButton(
                            action: { value = value * 10 + 7 }, text: "7", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { value = value * 10 + 8 }, text: "8", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { value = value * 10 + 9 }, text: "9", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: {
                                self.calculate()

                                self.prevValue = value
                                self.operation = .divide
                                self.value = 0
                            }, text: "/", isNumber: false, length: length)
                    }
                    HStack(spacing: 3) {
                        AppendingItemAmountInputButton(
                            action: { value = 0 }, text: "AC", isNumber: false, length: length)
                        AppendingItemAmountInputButton(
                            action: { value = value * 10 + 4 }, text: "4", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { value = value * 10 + 5 }, text: "5", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { value = value * 10 + 6 }, text: "6", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: {
                                self.calculate()

                                self.prevValue = value
                                self.operation = .multiplier
                                self.value = 0
                            }, text: "X", isNumber: false, length: length)
                    }
                    HStack(spacing: 3) {
                        Color.clear
                        AppendingItemAmountInputButton(
                            action: { value = value * 10 + 1 }, text: "1", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { value = value * 10 + 2 }, text: "2", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { value = value * 10 + 3 }, text: "3", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: {
                                self.calculate()

                                self.prevValue = value
                                self.operation = .subtraction
                                self.value = 0
                            }, text: "-", isNumber: false, length: length)
                    }
                    HStack(spacing: 3) {
                        AppendingItemAmountInputButton(
                            action: { value = value * 10 }, text: "0", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: { value = value * 100 }, text: "00", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: {
                                self.calculate()

                                self.prevValue = value
                                self.operation = .point
                                self.value = 0
                            }, text: ".", isNumber: true, length: length)
                        AppendingItemAmountInputButton(
                            action: {
                                self.calculate()
                            }, text: "=", isNumber: false, length: length)
                        AppendingItemAmountInputButton(
                            action: {
                                self.calculate()

                                self.prevValue = value
                                self.operation = .add
                                self.value = 0
                            }, text: "+", isNumber: false, length: length)
                    }
                }
            }
        }
        .background(Color.customOrange1)
    }

    private func calculate() {
        guard let operation else { return }

        switch operation {
        case .divide:
            self.value = prevValue / value
        case .multiplier:
            self.value = prevValue * value
        case .add:
            self.value = prevValue + value
        case .subtraction:
            self.value = prevValue - value
        case .point:
            break
        }

        self.operation = nil
    }
}

struct AppendingItemAmountInputButton: View {
    let action: () -> Void
    let text: String
    let isNumber: Bool
    let length: Int

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.Pretendard(size: 17, weight: .bold))
                .foregroundStyle(Color(uiColor: .systemBackground))
                .frame(width: CGFloat(length), height: CGFloat(length))
                .background(
                    isNumber
                        ? Color(uiColor: .systemBackground).opacity(0.24)
                        : Color(red: 248 / 255, green: 179 / 255, blue: 89 / 255)
                )
                .clipShape(Circle())
        }
    }

    init(action: @escaping () -> Void, text: String, isNumber: Bool, length: Int) {
        self.action = action
        self.text = text
        self.isNumber = isNumber
        self.length = length
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    AppendingItemView2(isExpense: true)
}
