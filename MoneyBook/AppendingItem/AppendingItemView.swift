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
                        .fill(isPaid ? .clear : .gray)
                        .overlay {
                            Button {
                                self.isPaid = false
                            } label: {
                                Text("수입")
                                    .foregroundColor(isPaid ? .gray : .white)
                            }
                        }
                    Capsule()
                        .fill(isPaid ? .gray : .clear)
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
    @Binding var selection: String
    
    var categories: [String] = [
        "카테고리 1",
        "카테고리 2",
        "카테고리 3",
        "카테고리 4",
        "카테고리 5",
        "카테고리 6",
    ]
    
    var body: some View {
        HStack {
            Text("Category")
                .padding(.leading, 16)
            Spacer()
            Picker("Category", selection: $selection) {
                ForEach(self.categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
        }
    }
}

struct AppendingItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var amount: Double? = nil
    @State private var date = Date()
    @State private var isPaid = false
    @State private var selection: String = "카테고리 1"
    
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
                
                Button(action: self.addItem) {
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
    
    private func addItem() {
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
        
        do {
            try PersistenceController.shared.addItem(item)
        } catch {
            print("에러닷")
        }
    }
}

struct AppendingItemView_Previews: PreviewProvider {
    static var previews: some View {
        AppendingItemView()
    }
}
