//
//  TimelineDateView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/19.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy.MM.dd"
    return dateFormatter
}()

struct TimelineDateView: View {
    let date: Date

    var body: some View {
        Text(dateFormatter.string(from: date))
            .font(.system(.caption))
            .foregroundColor(Color(uiColor: .systemGray))
    }
}

struct TimelineDateView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineDateView(date: Date())
    }
}
