//
//  AppendingItemView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/16/24.
//

import SwiftData
import SwiftUI

struct AppendingItemView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query var expenseCategories: [CategoryCoreEntity]
    @Query var incomeCategories: [CategoryCoreEntity]

    var item: ItemCoreEntity?

    @State var isExpense: Bool
    @State var date: Date
    @State var category: CategoryCoreEntity?
    @State var amount: Double
    @State var title: String
    @State var note: String

    @State var inputType: AppendingInputType?

    var isOKEnabled: Bool {
        return category != nil && amount > 0 && !title.isEmpty
    }

    init(item: ItemCoreEntity? = nil) {
        if let item {
            self.item = item

            _isExpense = State<Bool>(initialValue: item.category?.isExpense ?? true)
            _date = State<Date>(initialValue: item.timestamp)
            _category = State<CategoryCoreEntity?>(initialValue: item.category)
            _amount = State<Double>(initialValue: item.amount)
            _title = State<String>(initialValue: item.title)
            _note = State<String>(initialValue: item.note)
        } else {
            _isExpense = State<Bool>(initialValue: true)
            _date = State<Date>(initialValue: Date())
            _category = State<CategoryCoreEntity?>(initialValue: nil)
            _amount = State<Double>(initialValue: 0)
            _title = State<String>(initialValue: "")
            _note = State<String>(initialValue: "")
        }

        _expenseCategories = Query(
            filter: #Predicate<CategoryCoreEntity> { category in
                category.isExpense
            },
            sort: \.title,
            order: .forward
        )
        _incomeCategories = Query(
            filter: #Predicate<CategoryCoreEntity> { category in
                !category.isExpense
            },
            sort: \.title,
            order: .forward
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                ScrollView {
                    AppendingContentsView(
                        isExpense: $isExpense,
                        date: $date,
                        category: $category,
                        amount: amount.formatted(),
                        title: $title,
                        note: $note,
                        inputType: $inputType
                    )
                    .padding([.top, .leading, .trailing], 20)
                    .padding(.bottom, 0)

                    Spacer()
                }
                .scrollBounceBehavior(.basedOnSize)

                if isOKEnabled {
                    Button {
                        submit()
                    } label: {
                        Text("OK")
                            .foregroundStyle(Color.white)
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                    }
                    .background(isExpense ? Color.customOrange1 : Color.customIndigo1)
                    .clipShape(RoundedCorner(radius: 15, corners: [.topLeft, .topRight]))
                } else {
                    Text("OK")
                        .foregroundStyle(Color.white)
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(.gray)
                        .clipShape(RoundedCorner(radius: 15, corners: [.topLeft, .topRight]))
                }

            }

            if inputType == .date {
                AppendingItemDateInputView(isExpense: $isExpense, selected: $date)
                    .frame(height: 430)
            } else if inputType == .category {
                AppendingItemCategoryInputView(
                    isExpense: $isExpense, categories: isExpense ? expenseCategories : incomeCategories,
                    selected: $category
                )
                .frame(height: 400)
            } else if inputType == .amount {
                AppendingItemAmountInputView(value: $amount, isExpense: $isExpense)
                    .frame(height: 400)
            }
        }
    }

    private func submit() {
        defer {
            dismiss()
        }

        guard let category else { return }

        if let item {
            item.timestamp = date
            item.category = category
            item.amount = amount
            item.title = title
            item.note = note
        } else {
            let newItem = ItemCoreEntity(amount: amount, note: note, timestamp: date, title: title)
            newItem.category = category
            modelContext.insert(newItem)
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
enum FocusType: Hashable {
    case title
    case note
}

struct AppendingContentsView: View {
    @Binding var isExpense: Bool
    @Binding var date: Date
    @Binding var category: CategoryCoreEntity?
    let amount: String
    @Binding var title: String
    @Binding var note: String

    @Binding var inputType: AppendingInputType?
    @FocusState var focused: FocusType?

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var weekDay: String {
        let weekDays: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let i = Calendar.current.component(.weekday, from: date)
        return weekDays[i - 1]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    Spacer()
                    Toggle(isOn: $isExpense, label: {})
                        .toggleStyle(AppendingItemTypeToggleStyle())
                        .onChange(of: isExpense) { _, _ in
                            category = nil
                        }
                }
                .padding(.bottom, 8)

                VStack(spacing: 0) {
                    AppendingItemItemView(
                        title: "날짜",
                        backgroundColor: backgroundColor(.date),
                        action: { select(.date) },
                        label: {
                            Text(dateFormatter.string(from: date))
                                .font(.Pretendard(size: 18, weight: .bold))
                            Text(LocalizedStringKey(weekDay))
                                .font(.Pretendard(size: 12, weight: .bold))
                        }
                    )
                    AppendingItemItemView(
                        title: "분류",
                        backgroundColor: backgroundColor(.category),
                        action: { select(.category) },
                        label: {
                            Text(category?.title ?? "")
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
                            Text("Note")
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

        if type == .title {
            if focused == .title {
                focused = nil
            } else {
                focused = .title
            }
        } else if type == .note {
            if focused == .note {
                focused = nil
            } else {
                focused = .note
            }
        } else {
            focused = nil
        }
    }

    func backgroundColor(_ type: AppendingInputType?) -> Color {
        let opacity = inputType == type ? 0.3 : 0.1
        let color = isExpense ? Color.customOrange1 : Color.customIndigo1

        return color.opacity(opacity)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    AppendingItemView()
        .modelContainer(PersistenceController.preview.container)
}
