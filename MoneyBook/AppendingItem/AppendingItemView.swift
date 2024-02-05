//
//  AppendingItemView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/27.
//

import Combine
import SwiftData
import SwiftUI

struct AppendingItemTypeView: View {
    @Binding var isPaid: Bool

    var body: some View {
        Capsule()
            .fill(.background)
            .overlay {
                HStack(spacing: 0) {
                    Capsule()
                        .fill(isPaid ? .orange : .clear)
                        .overlay {
                            Button {
                                self.isPaid = true
                            } label: {
                                Text("지출")
                                    .foregroundColor(isPaid ? .white : .gray)
                            }
                        }
                    Capsule()
                        .fill(isPaid ? .clear : .indigo)
                        .overlay {
                            Button {
                                self.isPaid = false
                            } label: {
                                Text("수입")
                                    .foregroundColor(isPaid ? .gray : .white)
                            }
                        }
                }
            }
    }
}

struct AppendingItemNumberInputView: View {
    let image: Image
    let title: String
    @StateObject var doubleStore: NumberStore<Double, FloatingPointFormatStyle<Double>>

    var body: some View {
        HStack(spacing: 0) {
            image
                .frame(width: 28)
                .padding(.all, 8)
            TextField("Amount", text: $doubleStore.text)
                .formatAndValidate(doubleStore) { $0 > 0 }
                .keyboardType(.decimalPad)
            Spacer()
        }
        .background()
        .cornerRadius(8)
    }
}

extension View {
    @ViewBuilder
    fileprivate func formatAndValidate<T: Numeric, F: ParseableFormatStyle>(
        _ numberStore: NumberStore<T, F>, errorCondition: @escaping (T) -> Bool
    ) -> some View {
        onChange(of: numberStore.text) { text in
            numberStore.error = false
            if let value = numberStore.getValue(), !errorCondition(value) {
                numberStore.error = false
            } else if text.isEmpty || text == numberStore.minusCharacter {
                numberStore.error = false
            } else {
                numberStore.error = true
            }
        }
        //        .foregroundColor(numberStore.error ? .red : .primary)
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .onSubmit {
            if numberStore.text.count > 1 && numberStore.text.suffix(1) == numberStore.decimalSeparator {
                numberStore.text.removeLast()
            }
        }
    }
}

class NumberStore<T: Numeric, F: ParseableFormatStyle>: ObservableObject
where F.FormatOutput == String, F.FormatInput == T {
    @Published var text: String
    let type: ValidationType
    let maxLength: Int
    let allowNegative: Bool
    private var backupText: String
    @Published var error: Bool = false
    private let locale: Locale
    let formatter: F

    init(
        text: String = "",
        type: ValidationType,
        maxLength: Int = 18,
        allowNegative: Bool = false,
        formatter: F,
        locale: Locale = .current
    ) {
        self.text = text
        self.type = type
        self.allowNegative = allowNegative
        self.formatter = formatter
        self.locale = locale
        backupText = text
        self.maxLength = maxLength == .max ? .max - 1 : maxLength
    }

    var result: T? {
        try? formatter.parseStrategy.parse(text)
    }

    func restore() {
        text = backupText
    }

    func backup() {
        backupText = text
    }

    lazy var decimalSeparator: String = {
        locale.decimalSeparator ?? "."
    }()

    private lazy var groupingSeparator: String = {
        locale.groupingSeparator ?? ""
    }()

    let minusCharacter = "-"

    private lazy var characters: String = {
        let number = "0123456789"
        switch type {
        case .int:
            return number + (allowNegative ? minusCharacter : "")
        case .double:
            return number + (allowNegative ? minusCharacter : "") + decimalSeparator
        }
    }()

    var minusCount: Int {
        text.components(separatedBy: minusCharacter).count - 1
    }

    // 检查是否为有效输入字符
    func characterValidator() -> Bool {
        text.allSatisfy { characters.contains($0) }
    }

    // 返回验证后的数字
    func getValue() -> T? {
        // 特殊处理（无内容、只有负号、浮点数首字母为小数点）
        if text.isEmpty || text == minusCharacter || (type == .double && text == decimalSeparator) {
            backup()
            return nil
        }

        // 用去除组分隔符后的字符串判断字符是否有效
        let pureText = text.replacingOccurrences(of: groupingSeparator, with: "")
        guard pureText.allSatisfy({ characters.contains($0) }) else {
            restore()
            return nil
        }

        // 处理多个小数点情况
        if type == .double {
            if text.components(separatedBy: decimalSeparator).count > 2 {
                restore()
                return nil
            }
        }

        // 多个负号情况
        if minusCount > 1 {
            restore()
            return nil
        }

        // 负号必须为首字母
        if minusCount == 1, !text.hasPrefix("-") {
            restore()
            return nil
        }

        // 判断长度
        guard text.count < maxLength + minusCount else {
            restore()
            return nil
        }

        // 将文字转换成数字，然后在转换为文字（保证文字格式正确）
        if let value = try? formatter.parseStrategy.parse(text) {
            let hasDecimalCharacter = text.contains(decimalSeparator)
            let zeroCount = text.trailingZerosCountAfterDecimal()
            text = formatter.format(value)
            // 保护最后的小数点（不特别处理的话，转换回来的文字可能不包含小数点）
            if hasDecimalCharacter, !text.contains(decimalSeparator) {
                text.append(decimalSeparator)
                text += (0..<zeroCount).map { _ in "0" }.joined(separator: "")
            }
            backup()
            return value
        } else {
            restore()
            return nil
        }
    }

    enum ValidationType {
        case int
        case double
    }
}

extension String {
    func trailingZerosCountAfterDecimal() -> Int {
        var count = 0
        var foundDecimal = false

        for char in self.reversed() {
            if char == "." {
                foundDecimal = true
                break
            }
        }

        for char in self.reversed() {
            if foundDecimal && char == "0" {
                count += 1
            } else if char != "0" {
                break
            }
        }

        return count
    }
}

struct AppendingItemTextInputView: View {
    let image: Image
    let title: String

    @Binding var text: String

    var body: some View {
        HStack(spacing: 0) {
            image
                .frame(width: 28)
                .padding(.all, 8)
            TextField(title, text: $text, prompt: Text(title))
            Spacer()
        }
        .background()
        .cornerRadius(8)
    }
}

struct AppendingItemDateInputView: View {
    @Binding var date: Date

    var body: some View {
        DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.graphical)
            .padding(.all, 8)
            .background()
            .cornerRadius(8)
    }
}

struct AppendingItemCategoryInputView: View {
    @Environment(\.modelContext) var modelContext

    @State var isAlertPresented = false
    @State var addingCategory = ""
    @State var isExpense: Bool
    @Binding var selection: CategoryCoreEntity

    @Query var categories: [CategoryCoreEntity]
    private var showingCategories: [CategoryCoreEntity] {
        self.categories.filter { $0.isExpense == self.isExpense }
    }

    var body: some View {
        HStack {
            Text("Category")
                .padding(.leading, 16)
            Spacer()
            Menu {
                ForEach(self.showingCategories) { category in
                    Button(category.title, action: { self.setCategory(category) })
                }
                Section {
                    Button("Add Category") {
                        self.isAlertPresented.toggle()
                    }
                }
            } label: {
                Label(selection.title, systemImage: "chevron.down")
                    .labelStyle(RightImageLabelStyle())
                    .padding(.all, 8)
            }
            .menuStyle(.button)
            .alert("Add Category", isPresented: $isAlertPresented) {
                VStack {
                    TextField("category", text: $addingCategory)
                    Picker("isExpense", selection: self.$isExpense) {
                        Text("지출").tag(true)
                        Text("소득").tag(false)
                    }
                }
                Button("OK") {
                    self.addCategory(self.addingCategory)
                    isAlertPresented.toggle()
                }
                Button("Cancel") {
                    isAlertPresented.toggle()
                }
            }
        }
    }

    private func setCategory(_ category: CategoryCoreEntity) {
        self.selection = category
    }

    private func addCategory(_ category: String) {
        self.modelContext.insert(CategoryCoreEntity(title: category, iconName: "carrot", isExpense: true))
    }
}

struct RightImageLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

struct AppendingItemView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var amount: Double?
    @StateObject var doubleStore: NumberStore<Double, FloatingPointFormatStyle<Double>>
    @State private var date: Date
    @State private var isPaid: Bool
    @State private var selection: CategoryCoreEntity

    private let item: ItemCoreEntity?

    init(item: ItemCoreEntity) {
        self.item = item

        self._title = State(initialValue: item.title)
        self._doubleStore = StateObject(
            wrappedValue: NumberStore(
                text: abs(item.amount).formatted(),
                type: .double,
                maxLength: 12,
                allowNegative: false,
                formatter: FloatingPointFormatStyle<Double>()
                    .precision(.fractionLength(0...2))
                    .rounded(rule: .towardZero)
            )
        )
        self._date = State(initialValue: item.timestamp)
        self._isPaid = State(initialValue: item.amount < 0)
        self._selection = State(initialValue: item.category)
    }

    init(initialCategory: CategoryCoreEntity) {
        self.item = nil

        self._title = State(initialValue: "")
        self._doubleStore = StateObject(
            wrappedValue: NumberStore(
                text: "",
                type: .double,
                maxLength: 12,
                allowNegative: false,
                formatter: FloatingPointFormatStyle<Double>()
                    .precision(.fractionLength(0...2))
                    .rounded(rule: .towardZero)
            )
        )
        self._date = State(initialValue: Date())
        self._isPaid = State(initialValue: true)
        self._selection = State(initialValue: initialCategory)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    Spacer()
                    AppendingItemTypeView(isPaid: $isPaid)
                        .frame(width: 200, height: 44)
                    Spacer()
                }
                AppendingItemTextInputView(
                    image: Image(systemName: "t.square"), title: "Title", text: $title)
                AppendingItemNumberInputView(
                    image: Image(systemName: "dollarsign"), title: "Amount", doubleStore: self.doubleStore)
                AppendingItemDateInputView(date: $date)
                AppendingItemCategoryInputView(isExpense: self.isPaid, selection: $selection)
                    .background(.background)
                    .cornerRadius(8)

                Button(action: self.submit) {
                    Text("Done")
                        .font(.callout)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .background()
                .cornerRadius(8)
                .padding(.top, 40)

                Spacer()
            }
            .padding([.leading, .trailing], 32)

        }
        .background(Color(uiColor: .secondarySystemBackground))
        .foregroundStyle(self.isPaid ? .orange : .indigo)
        .tint(self.isPaid ? .orange : .indigo)
    }

    private func submit() {
        let amount = (self.isPaid ? -1 : 1) * (self.doubleStore.getValue() ?? 0)

        defer {
            dismiss()
        }

        if let coreItem = self.item {
            coreItem.amount = amount
            coreItem.category = self.selection
            coreItem.timestamp = self.date
            coreItem.title = self.title
        } else {
            let item = ItemCoreEntity(
                amount: amount,
                category: self.selection,
                timestamp: self.date,
                title: self.title
            )
            self.modelContext.insert(item)
        }
    }

}

struct AppendingItemView_Previews: PreviewProvider {
    static var previews: some View {
        AppendingItemView(initialCategory: CategoryCoreEntity(title: "test", iconName: "carrot", isExpense: true))
    }
}
