//
//  TimelineItemView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/11.
//

import SwiftUI

struct TimelineItemView: View {
    let title: String
    let imageName: String
    let categoryName: String
    let amount: Int
    
    var body: some View {
        HStack {
            Image(systemName: self.imageName)
            VStack(alignment: .leading) {
                Spacer()
                Text(self.title)
                    .font(.system(size: 16, weight: .bold))
                HStack {
                    Text(self.categoryName)
                        .font(.system(size: 12, weight: .medium))
                    Spacer()
                    Text(amountFormatter.string(for: self.amount) ?? "")
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
            }
        }
        .padding([.leading, .trailing], 12)
        .background(self.amount > 0 ? Color.indigo : Color.orange)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .foregroundColor(.white)
    }
}

public let amountFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.positivePrefix = "+"
    formatter.negativePrefix = "-"
    return formatter
}()

struct TimelineItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimelineItemView(title: "신미방 마라탕", imageName: "carrot", categoryName: "식비", amount: 32000)
                .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/250.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/80.0/*@END_MENU_TOKEN@*/))
            TimelineItemView(title: "신미방 마라탕", imageName: "carrot", categoryName: "식비", amount: -32000)
                .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/250.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/80.0/*@END_MENU_TOKEN@*/))
        }
    }
}
