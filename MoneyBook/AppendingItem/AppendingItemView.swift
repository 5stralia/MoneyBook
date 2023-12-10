//
//  AppendingItemView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/27.
//

import Combine
import SwiftUI

struct AppendingItemTypeView: View {
    @Binding var isPaid: Bool

    var body: some View {
        Capsule()
            .fill(.background)
            .overlay {
                HStack(spacing: 0) {
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
                }
            }
    }
}

struct AppendingItemNumberInputView: View {
    let image: Image
    let title: String

    @Binding var value: Double?

    var body: some View {
        HStack(spacing: 0) {
            image
                .frame(width: 28)
                .padding(.all, 8)
            TextField("Amount", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .onReceive(Just(value)) { newValue in
                    guard let newValue, newValue < 0 else { return }
                    self.value = -newValue
                }
            Spacer()
        }
        .background()
        .cornerRadius(8)
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
    @State var isAlertPresented = false
    @State var addingCategory = ""
    @Binding var selection: String

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryCoreEntity.title, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<CategoryCoreEntity>

    var body: some View {
        HStack {
            Text("Category")
                .padding(.leading, 16)
            Spacer()
            Menu {
                ForEach(self.categories) { category in
                    Button(category.title, action: { self.setCategory(category.title) })
                }
                Section {
                    Button("Add Category") {
                        self.isAlertPresented.toggle()
                    }
                }
            } label: {
                Label(selection, systemImage: "chevron.down")
                    .labelStyle(RightImageLabelStyle())
                    .padding(.all, 8)
                    .foregroundColor(.blue)
            }
            .menuStyle(.button)
            .alert("Add Category", isPresented: $isAlertPresented) {
                TextField("category", text: $addingCategory)
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

    private func setCategory(_ category: String) {
        self.selection = category
    }

    private func addCategory(_ category: String) {
        do {
            try PersistenceController.shared.addCategory(category)
        } catch {
            print("에러닷!!!")
        }
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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var amount: Double?
    @State private var date: Date
    @State private var isPaid: Bool
    @State private var selection: String

    private let item: ItemCoreEntity?

    init(item: ItemCoreEntity?) {
        self.item = item

        if let item {
            self._title = State(initialValue: item.title)
            self._amount = State(initialValue: abs(item.amount))
            self._date = State(initialValue: item.timestamp)
            self._isPaid = State(initialValue: item.amount < 0)
            self._selection = State(initialValue: item.category)
        } else {
            self._title = State(initialValue: "")
            self._amount = State(initialValue: nil)
            self._date = State(initialValue: Date())
            self._isPaid = State(initialValue: false)
            self._selection = State(initialValue: "기타")
        }
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
                AppendingItemTextInputView(image: Image(systemName: "t.square"), title: "Title", text: $title)
                AppendingItemNumberInputView(image: Image(systemName: "dollarsign"), title: "Amount", value: $amount)
                AppendingItemDateInputView(date: $date)
                AppendingItemCategoryInputView(selection: $selection)
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
    }

    private func submit() {
        let amount = (self.isPaid ? -1 : 1) * (self.amount ?? 0)
        let item = ItemEntity(
            amount: amount,
            category: self.selection,
            group_id: UUID(),
            note: "",
            timestamp: self.date,
            title: self.title
        )

        defer {
            dismiss()
        }

        if let coreItem = self.item {
            self.updateItem(item, coreItem: coreItem)
        } else {
            self.addItem(item)
        }
    }

    private func addItem(_ item: ItemEntity) {
        do {
            try PersistenceController.shared.addItem(item)
        } catch {
            print("에러닷")
        }
    }

    private func updateItem(_ item: ItemEntity, coreItem: ItemCoreEntity) {
        do {
            try PersistenceController.shared.updateItem(item, coreItem: coreItem)
        } catch {
            print("에러닷")
        }
    }
}

struct AppendingItemView_Previews: PreviewProvider {
    static var previews: some View {
        AppendingItemView(item: nil)
    }
}
