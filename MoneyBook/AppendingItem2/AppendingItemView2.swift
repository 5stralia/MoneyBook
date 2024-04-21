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

enum AppendingInputType {
    case date
    case category
    case amount
}

struct AppendingContentsView: View {
    @Binding var isExpense: Bool
    @State var title: String = ""
    @State var note: String = ""

    @Binding var inputType: AppendingInputType?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    Spacer()
                    AppendingItemTypeView2(isPaid: $isExpense)
                        .frame(width: 118, height: 32)
                }
                .padding(.bottom, 8)

                VStack(spacing: 24) {
                    HStack {
                        Text("날짜")
                            .font(.Pretendard(size: 15, weight: .bold))
                        Spacer()
                        Button {

                        } label: {
                            Text("2024.02.19")
                                .font(.Pretendard(size: 18, weight: .bold))
                            Text("화")
                                .font(.Pretendard(size: 12, weight: .bold))
                        }
                        .foregroundStyle(Color.primary)
                    }
                    HStack {
                        Text("분류")
                            .font(.Pretendard(size: 15, weight: .bold))
                        Spacer()
                        Button {

                        } label: {
                            Text("반려동물")
                                .font(.Pretendard(size: 15, weight: .bold))
                        }
                        .foregroundStyle(Color.primary)
                    }
                    HStack {
                        Text("금액")
                            .font(.Pretendard(size: 15, weight: .bold))
                        Spacer()
                        Button {
                            inputType = .amount
                        } label: {
                            Text("1,469,800")
                                .font(.Pretendard(size: 15, weight: .bold))
                        }
                        .foregroundStyle(Color.primary)
                    }
                    HStack {
                        Text("이름")
                            .font(.Pretendard(size: 15, weight: .bold))
                            .foregroundStyle(Color.customOrange1)
                        Spacer()

                        TextField("", text: $title)
                            .font(.Pretendard(size: 15, weight: .bold))
                            .foregroundStyle(Color.customOrange1)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding([.top, .bottom], 13)
                .padding([.leading, .trailing], 23)
                .background(Color.customOrange1.opacity(0.3))
                .clipShape(RoundedCorner(radius: 11))
                .padding(.bottom, 17)

                HStack(alignment: .top) {
                    Text("메모")
                        .font(.Pretendard(size: 15, weight: .bold))
                    Spacer()
                    TextField("", text: $note, axis: .vertical)
                        .font(.Pretendard(size: 15, weight: .regular))
                        .multilineTextAlignment(.trailing)
                }
                .padding([.top, .bottom], 13)
                .padding([.leading, .trailing], 23)
                .background(Color(uiColor: .systemGray5).opacity(0.3))
                .clipShape(RoundedCorner(radius: 11))
            }
        }
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
                                    .foregroundColor(isPaid ? .white : Color(uiColor: .systemGray4))
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
                                    .foregroundColor(isPaid ? Color(uiColor: .systemGray4) : .white)
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
