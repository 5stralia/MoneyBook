//
//  SettingSectionHeader.swift
//  MoneyBook
//
//  Created by Hoju Choi on 5/4/24.
//

import SwiftUI

struct SettingSectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.Pretendard(size: 13, weight: .medium))
                .foregroundStyle(Color.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.leading, 16)
        .padding(.top, 12)
        .padding(.bottom, 6)
        .background(Color(uiColor: .systemGray6))
    }
}

#Preview {
    SettingSectionHeader(title: "데이터")
}
