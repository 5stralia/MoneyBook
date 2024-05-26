//
//  SettingItemView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 5/4/24.
//

import SwiftUI

struct SettingItemView: View {
    let imageSystemName: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: imageSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.leading, 13)

            Text(title)
                .font(.Pretendard(size: 14, weight: .semiBold))
        }
        .padding([.top, .bottom], 10)
        .frame(height: 44)
    }
}

#Preview {
    SettingItemView(imageSystemName: "dog", title: "내보내기")
}
