//
//  AppendingItemCategoryInputView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/27/24.
//

import SwiftUI

struct AppendingItemCategoryInputView: View {
    @Environment(\.modelContext) var modelContext

    struct AnimationValues {
        var angle = Angle.degrees(0)
        var offset = CGSize(width: 0, height: 0)
    }

    @Binding var isExpense: Bool
    let categories: [CategoryCoreEntity]
    @Binding var selected: CategoryCoreEntity?
    @FocusState private var isNewCategoryFocused: Bool
    @FocusState private var isEditCategoryFocused: Bool

    @State private var isEditing: Bool = false
    @State private var editingSelected: CategoryCoreEntity?
    @State private var editingCategoryName: String = ""

    @State private var isSetting: Bool = false

    @State private var isAdding: Bool = false
    @State private var newCategoryName: String = "새분류"

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
                    isAdding.toggle()
                    isNewCategoryFocused.toggle()
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
            .padding(.bottom, 10)
            .padding([.leading, .top, .trailing], 20)

            GeometryReader { reader in
                let cols: Double = 5
                let length = (reader.size.width - (36 * 2) - (6 * (cols - 1))) / cols

                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(Array(stride(from: 0, to: categories.endIndex, by: 5)), id: \.self) { i in
                            HStack {
                                ForEach(Array(stride(from: i, to: min(categories.endIndex, i + 5), by: 1)), id: \.self)
                                { j in
                                    let category = categories[j]
                                    let isSelected = category == selected

                                    Button {
                                        if isSetting {
                                            isEditing = true
                                            editingSelected = category
                                        } else {
                                            selected = category
                                        }
                                    } label: {
                                        ZStack(alignment: .topLeading) {
                                            ZStack(alignment: .center) {
                                                Color(uiColor: .systemBackground).opacity(isSelected ? 1.0 : 0.24)
                                                    .clipShape(Circle())

                                                if isSetting {
                                                    if editingSelected != nil && category == editingSelected {
                                                        TextField("", text: $editingCategoryName)
                                                            .font(.Pretendard(size: 13, weight: .semiBold))
                                                            .foregroundStyle(Color(uiColor: .systemBackground))
                                                            .multilineTextAlignment(.center)
                                                            .focused($isEditCategoryFocused)
                                                            .onReceive(
                                                                NotificationCenter.default.publisher(
                                                                    for: UITextField.textDidBeginEditingNotification
                                                                )
                                                            ) { obj in
                                                                if let textField = obj.object as? UITextField {
                                                                    textField.selectedTextRange =
                                                                        textField.textRange(
                                                                            from: textField.beginningOfDocument,
                                                                            to: textField.endOfDocument)
                                                                }
                                                            }
                                                            .onSubmit {
                                                                category.title = editingCategoryName
                                                                isEditing = false
                                                                isSetting = false
                                                            }
                                                    } else {
                                                        Text(category.title)
                                                            .font(.Pretendard(size: 13, weight: .semiBold))
                                                            .foregroundStyle(
                                                                isSelected
                                                                    ? Color.primary
                                                                    : Color(uiColor: .systemBackground))
                                                    }
                                                } else {
                                                    Text(category.title)
                                                        .font(.Pretendard(size: 13, weight: .semiBold))
                                                        .foregroundStyle(
                                                            isSelected
                                                                ? Color.primary : Color(uiColor: .systemBackground))
                                                }
                                            }

                                            if isSetting {
                                                ZStack(alignment: .center) {
                                                    Color.red
                                                        .clipShape(Circle())
                                                    Image(systemName: "ellipsis")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .padding(.all, 4)
                                                        .foregroundStyle(Color.white)
                                                }
                                                .frame(width: length / 3, height: length / 3)
                                            }
                                        }
                                        .frame(width: CGFloat(length), height: CGFloat(length))
                                        .keyframeAnimator(
                                            initialValue: AnimationValues(),
                                            repeating: isSetting
                                        ) { content, value in
                                            content
                                                .rotationEffect(isSetting ? value.angle : .zero, anchor: .center)
                                                .offset(isSetting ? value.offset : .zero)
                                        } keyframes: { _ in
                                            KeyframeTrack(\.angle) {
                                                LinearKeyframe(Angle.degrees(-10), duration: 0.1)
                                                LinearKeyframe(Angle.degrees(10), duration: 0.2)
                                                LinearKeyframe(Angle.zero, duration: 0.1)
                                            }
                                        }
                                    }
                                    .alert("\(editingSelected?.title ?? "-1")", isPresented: $isEditing) {
                                        Button("Delete") {
                                            isEditing = false
                                            if let deletion = editingSelected {
                                                modelContext.delete(deletion)
                                            }
                                            editingSelected = nil
                                        }
                                        Button("Edit") {
                                            isEditing = false
                                            isEditCategoryFocused = true
                                            if let editting = editingSelected {
                                                editingCategoryName = editting.title
                                            }
                                        }
                                        Button("Cancel", role: .cancel) {
                                            isEditing = false
                                            editingSelected = nil
                                        }
                                    }
                                }

                                if isAdding && categories.count % 5 != 0 {
                                    ZStack(alignment: .center) {
                                        Color(uiColor: .systemBackground).opacity(0.24)
                                            .clipShape(Circle())

                                        TextField("", text: $newCategoryName)
                                            .font(.Pretendard(size: 13, weight: .semiBold))
                                            .foregroundStyle(Color(uiColor: .systemBackground))
                                            .multilineTextAlignment(.center)
                                            .focused($isNewCategoryFocused)
                                            .onReceive(
                                                NotificationCenter.default.publisher(
                                                    for: UITextField.textDidBeginEditingNotification)
                                            ) { obj in
                                                if let textField = obj.object as? UITextField {
                                                    textField.selectedTextRange = textField.textRange(
                                                        from: textField.beginningOfDocument, to: textField.endOfDocument
                                                    )
                                                }
                                            }
                                            .onSubmit {
                                                addCategory()
                                            }
                                    }
                                    .frame(width: CGFloat(length), height: CGFloat(length))
                                }
                            }
                        }
                        .padding([.leading, .trailing], 36)

                        if isAdding && categories.count % 5 == 0 {
                            ZStack(alignment: .center) {
                                Color(uiColor: .systemBackground).opacity(0.24)
                                    .clipShape(Circle())

                                TextField("", text: $newCategoryName)
                                    .font(.Pretendard(size: 13, weight: .semiBold))
                                    .foregroundStyle(Color(uiColor: .systemBackground))
                                    .multilineTextAlignment(.center)
                                    .focused($isNewCategoryFocused)
                                    .onReceive(
                                        NotificationCenter.default.publisher(
                                            for: UITextField.textDidBeginEditingNotification)
                                    ) { obj in
                                        if let textField = obj.object as? UITextField {
                                            textField.selectedTextRange = textField.textRange(
                                                from: textField.beginningOfDocument, to: textField.endOfDocument
                                            )
                                        }
                                    }
                                    .onSubmit {
                                        addCategory()
                                    }
                            }
                            .frame(width: CGFloat(length), height: CGFloat(length))
                            .padding(.leading, 36)
                        }
                    }
                    .padding([.top, .bottom], 10)
                }
            }
        }
        .foregroundStyle(Color.white)
        .background(isExpense ? Color.customOrange1 : Color.customIndigo1)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
    }

    private func addCategory() {
        let entity = CategoryCoreEntity(title: newCategoryName, isExpense: isExpense)
        entity.group = GroupManager.shared.currentGroup
        modelContext.insert(entity)
        isAdding = false
    }
}

#Preview {
    AppendingItemCategoryInputView(
        isExpense: .constant(true),
        categories: (1...10).map { i in .init(title: "cate\(i)", isExpense: true) },
        selected: .constant(nil)
    )
}
