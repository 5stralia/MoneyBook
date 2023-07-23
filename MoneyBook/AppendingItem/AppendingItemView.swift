//
//  AppendingItemView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/27.
//

import SwiftUI

struct AppendingItemTypeView: View {
    @State var isPaid = false
    
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

struct AppendingItemTextInputView: View {
    private let image: Image
    private let title: String
    
    @State var text: String = ""
    
    init(image: Image, title: String) {
        self.image = image
        self.title = title
    }
    
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
    @State var date: Date = Date()
    
    var body: some View {
        DatePicker("Date", selection: $date, displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .padding(.all, 8)
            .background()
            .cornerRadius(8)
    }
}

struct AppendingItemCategoryInputView: View {
    private let image: Image
    private let title: String
    
    init(image: Image, title: String) {
        self.image = image
        self.title = title
    }
    
    var body: some View {
        HStack(spacing: 0) {
            image
                .frame(width: 28)
                .padding(.all, 8)
            Button {
                //
            } label: {
                Text(title)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .background()
        .cornerRadius(8)
    }
}

struct AppendingItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var isPaid = false
    @State var selection = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Spacer()
                AppendingItemTypeView(isPaid: isPaid)
                    .frame(width: 200, height: 44)
                    .padding([.top, .bottom], 40)
                Spacer()
            }
            AppendingItemTextInputView(image: Image(systemName: "t.square"), title: "Title")
                .padding([.leading, .trailing], 32)
                .padding([.top, .bottom], 10)
            AppendingItemTextInputView(image: Image(systemName: "dollarsign"), title: "Amount")
                .padding([.leading, .trailing], 32)
                .padding([.top, .bottom], 10)
            AppendingItemDateInputView()
                .padding([.leading, .trailing], 32)
                .padding([.top, .bottom], 10)
            
            HStack {
                Text("카테고리")
                    .padding(.leading, 16)
                Spacer()
                Picker("카테고리", selection: $selection) {
                    ForEach((0..<50)) { i in
                        Text("Selection \(i)").tag(i)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)
            }
            .background(.white)
            .cornerRadius(8)
            .padding([.leading, .trailing], 32)
            
            Button {
                //
            } label: {
                Text("확인")
                    .font(.callout)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .background()
            .cornerRadius(8)
            .padding([.leading, .trailing], 32)
            .padding(.top, 40)
            
            Spacer()
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

struct AppendingItemView_Previews: PreviewProvider {
    static var previews: some View {
        AppendingItemView()
    }
}
