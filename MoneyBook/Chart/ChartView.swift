//
//  ChartView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/08/10.
//

import Foundation
import Charts
import SwiftUI

struct ValuePerCategory {
    var category: String
    var value: Double
}

struct ChartView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemCoreEntity.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ItemCoreEntity>
    
    private var values: [ValuePerCategory] {
        let grouping = Dictionary(grouping: self.items) { $0.category }
        
        return grouping.map { key, value in
            ValuePerCategory(category: key, value: value.reduce(0, { $0 + $1.amount }))
        }
    }
    
    var body: some View {
        ScrollView {
            Chart(self.values.sorted(by: { $0.value > $1.value }), id: \.category) { item in
                BarMark(
                    x: .value("Value", item.value),
                    stacking: .normalized
                )
                .foregroundStyle(by: .value("Category", item.category))
            }
            
            Chart(self.values.sorted(by: { $0.value > $1.value }), id: \.category) { item in
                BarMark(
                    x: .value("Value", item.value),
                    y: .value("Category", item.category)
                )
                .annotation(position: .trailing, alignment: .trailing) {
                    HStack {
                        Text(item.category)
                            .font(.caption)
                        Text("(\(formatter.string(from: item.value as NSNumber)!))")
                            .font(.caption2)
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: CGFloat(self.values.count) * 32)
            .tint(.blue)
            
        }
        .padding([.leading, .trailing], 8)
    }
}

private let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
