//
//  TimelineAddButton.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/21/24.
//

import SwiftUI

struct TimelineAddButton: View {
    var body: some View {
        Circle()
            .frame(width: 60, height: 60)
            .overlay {
                Image("add")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .foregroundStyle(Color(uiColor: .systemBackground))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.16), radius: 6, y: 3)
    }
}

#Preview {
    TimelineAddButton()
}
