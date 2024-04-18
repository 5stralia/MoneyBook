//
//  Header.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/23/24.
//

import SwiftUI

struct Header: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let topText: String
    let title: String
    let isHiddenBackButton: Bool
    let action: (() -> Void)?

    internal init(
        topText: String, title: String, isHiddenBackButton: Bool = true, action: (() -> Void)? = nil
    ) {
        self.topText = topText
        self.title = title
        self.isHiddenBackButton = isHiddenBackButton
        self.action = action
    }

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                VStack {
                    Text(self.topText)
                        .font(.Pretendard(size: 11, weight: .medium))

                    if let action {
                        Button(
                            action: action,
                            label: {
                                HStack {
                                    Text(self.title)
                                        .font(.Pretendard(size: 20, weight: .semiBold))
                                    Image(systemName: "chevron.down")
                                }
                            })
                    } else {
                        Text(self.title)
                            .font(.Pretendard(size: 23))
                    }
                }
                Spacer()
            }

            if !self.isHiddenBackButton {
                HStack {
                    Button(
                        action: {
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        label: {
                            Text("Back")
                                .padding(.leading, 16)
                        })

                    Spacer()
                }
            }
        }
        .zIndex(.infinity)
        .padding(.bottom, 11)
        .padding(.top, 20)
        .foregroundStyle(Color.primary)
        .background {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(Color(uiColor: .systemGray6))
                .shadow(color: Color.black.opacity(0.16), radius: 6, x: 0, y: 3)
        }
    }

    func trailingContent(_ content: () -> some View) -> some View {
        self.overlay(
            alignment: .bottomTrailing,
            content: { content().padding(.trailing, 16).padding(.bottom, 11) }
        )
    }
}

#Preview {
    Group {
        Header(topText: "부가설명", title: "제목", isHiddenBackButton: true, action: nil)
        Header(topText: "부가설명", title: "제목", isHiddenBackButton: false, action: nil)
        Header(topText: "부가설명", title: "제목", isHiddenBackButton: true, action: {})
        Header(topText: "부가설명", title: "제목", isHiddenBackButton: false, action: {})
        Header(topText: "부가설명", title: "제목", isHiddenBackButton: true, action: {})
            .trailingContent({
                Button(
                    action: {},
                    label: {
                        Text("Button")
                    })
            })
    }
}
