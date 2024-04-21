//
//  AppendingItemView2.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/16/24.
//

import SwiftUI

struct AppendingItemView2: View {
    @State var isExpense: Bool = true
    @State var date: Date = Date()
    @State var category: String = "카테고0"
    @State var amount: Double = 0
    @State var title: String = ""
    @State var note: String = ""

    @State var inputType: AppendingInputType?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Header(topText: "", title: "append", isHiddenBackButton: false)

                AppendingContentsView(
                    isExpense: $isExpense,
                    category: $category,
                    amount: amount.formatted(),
                    title: $title,
                    note: $note,
                    inputType: $inputType
                )
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
                AppendingItemCategoryInputView(isExpense: $isExpense, categories: (0...30).map({ "카테고\($0)"}), selected: $category)
                    .frame(height: 400)
            } else if inputType == .amount {
                AppendingItemAmountInputView(value: $amount, isExpense: $isExpense)
                    .frame(height: 400)
            }
        }
        .ignoresSafeArea(edges: .bottom)
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
    @Binding var category: String
    let amount: String
    @Binding var title: String
    @Binding var note: String

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
                            Text(category)
                                .font(.Pretendard(size: 15, weight: .bold))
                        }
                    )
                    AppendingItemItemView(
                        title: "금액",
                        backgroundColor: backgroundColor(.amount),
                        action: { select(.amount) },
                        label: {
                            Text(amount)
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
        VStack(alignment: .trailing) {
            Text(currentValue.formatted)
                .font(.Pretendard(size: 18, weight: .bold))
                .foregroundStyle(Color(uiColor: .systemBackground))
                .padding([.top, .bottom], 22)
                .padding(.trailing, 10)

            GeometryReader { reader in
                let length = Int((reader.size.width - (3 * 4)) / 5)
                VStack {
                    HStack(spacing: 3) {
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
                    HStack(spacing: 3) {
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
                    HStack(spacing: 3) {
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
                    HStack(spacing: 3) {
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
            }
        }
        .padding([.leading, .bottom, .trailing], 8)
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
        case .doubleZero:
            currentValue.original = currentValue.original * 100
        case .divide:
            calculate()
            prevValue = currentValue
            operation = .divide
            currentValue = Value()
        case .multiplier:
            calculate()
            prevValue = currentValue
            operation = .multiplier
            currentValue = Value()
        case .add:
            calculate()
            prevValue = currentValue
            operation = .add
            currentValue = Value()
        case .subtraction:
            calculate()
            prevValue = currentValue
            operation = .subtraction
            currentValue = Value()
        case .point:
            guard !isFloating else { break }

            isFloating = true
        case .clear:
            prevValue = Value()
            operation = nil
            currentValue = Value()
            isFloating = false
        case .remove:
            if currentValue.floating > 1 {
                currentValue.original = Double(Int(currentValue.original / 10))
                currentValue.floating /= 10
            } else {
                currentValue.original = Double(Int(currentValue.original / 10))
            }
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
                        : Color.black.opacity(0.1)
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

struct AppendingItemCategoryInputView: View {
    struct AnimationValues {
        var angle = Angle.degrees(0)
        var offset = CGSize(width: 0, height: 0)
    }
    
    @Binding var isExpense: Bool
    let categories: [String]
    @Binding var selected: String
    
    @State private var isSetting: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    // TODO: 설정. 카테고리 제거 및 수정 UI를 띄운다.
                    isSetting.toggle()
                } label: {
                    ZStack(alignment: .center) {
                        Color.black.opacity(0.2)
                            .clipShape(Circle())
                            .padding(.all, 7)
                        
                        Image(systemName: "hammer.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.all, 13)
                    }
                    .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Button {
                    // TODO: 카테고리 추가
                } label: {
                    ZStack(alignment: .center) {
                        Color.black.opacity(0.2)
                            .clipShape(Circle())
                            .padding(.all, 7)
                        
                        Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.all, 13)
                    }
                    .frame(width: 44, height: 44)
                }
            }
            .padding(.all, 20)
            
            
            GeometryReader { reader in
                let cols: Double = 5
                let length = (reader.size.width - (36 * 2) - (6 * (cols - 1))) / cols
                
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(Array(stride(from: 0, to: categories.endIndex, by: 5)), id: \.self) { i in
                            HStack {
                                ForEach(Array(stride(from: i, to: min(categories.endIndex, i + 5), by: 1)), id: \.self) { j in
                                    let category = categories[j]
                                    let isSelected = category == selected
                                    
                                    Button {
                                        selected = category
                                    } label: {
                                        ZStack(alignment: .center) {
                                            Color(uiColor: .systemBackground).opacity(isSelected ? 1.0 : 0.24)
                                                .clipShape(Circle())
                                            
                                            if isSetting {
                                                Text(category)
                                                    .font(.Pretendard(size: 13, weight: .semiBold))
                                                    .foregroundStyle(isSelected ? Color.primary : Color(uiColor: .systemBackground))
                                                
                                            } else {
                                                Text(categories[j])
                                                    .font(.Pretendard(size: 13, weight: .semiBold))
                                                    .foregroundStyle(isSelected ? Color.primary : Color(uiColor: .systemBackground))
                                            }
                                        }
                                        .frame(width: CGFloat(length), height: CGFloat(length))
                                        .keyframeAnimator(
                                            initialValue: AnimationValues(),
                                            repeating: isSetting) { content, value in
                                                content
                                                    .rotationEffect(isSetting ? value.angle : .zero, anchor: .center)
                                                    .offset(isSetting ? value.offset : .zero)
                                            } keyframes: { _ in
                                                KeyframeTrack(\.angle) {
                                                    LinearKeyframe(Angle.degrees(-20), duration: 0.1)
                                                    LinearKeyframe(Angle.degrees(20), duration: 0.2)
                                                    LinearKeyframe(Angle.zero, duration: 0.1)
                                                }
                                                
                                                KeyframeTrack(\.offset) {
                                                    LinearKeyframe(CGSize(width: -3, height: -3), duration: 0.1)
                                                    LinearKeyframe(CGSize(width: 3, height: 3), duration: 0.2)
                                                    LinearKeyframe(CGSize.zero, duration: 0.1)
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .padding([.leading, .trailing], 36)
                    }
                }
            }
        }
        .foregroundStyle(Color.white)
        .background(isExpense ? Color.customOrange1 : Color.customIndigo1)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    AppendingItemView2(isExpense: true)
}
