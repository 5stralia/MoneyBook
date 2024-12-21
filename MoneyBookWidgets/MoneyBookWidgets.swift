//
//  MoneyBookWidgets.swift
//  MoneyBookWidgets
//
//  Created by Hoju Choi on 12/14/23.
//

import SwiftUI
import WidgetKit
import SwiftData

struct Provider: TimelineProvider {
    private let modelContainer = PersistenceController.shared.container
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), expense: 200000, income: 450000)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let descriptor = FetchDescriptor<ItemCoreEntity>()
        
        Task {
            guard let items = try? await modelContainer.mainContext.fetch(descriptor) else {
                completion(SimpleEntry(date: Date(), expense: 0, income: 0))
                return
            }
            
            let currentMonth = Calendar.current.component(.month, from: Date())
            let filterdItems = items.filter { item in
                let itemMonth = Calendar.current.component(.month, from: item.timestamp)
                return currentMonth == itemMonth
            }
            
            let expense = filterdItems.filter { $0.category?.isExpense == true }.map { $0.amount }.reduce(0, +)
            let income = filterdItems.filter { $0.category?.isExpense == false }.map { $0.amount }.reduce(0, +)
            let entry = SimpleEntry(date: Date(), expense: expense, income: income)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let descriptor = FetchDescriptor<ItemCoreEntity>()
        
        Task {
            guard let items = try? await modelContainer.mainContext.fetch(descriptor) else {
                let timeline = Timeline(entries: [SimpleEntry(date: Date(), expense: 0, income: 0)], policy: .atEnd)
                completion(timeline)
                return
            }
            
            let currentMonth = Calendar.current.component(.month, from: Date())
            let filterdItems = items.filter { item in
                let itemMonth = Calendar.current.component(.month, from: item.timestamp)
                return currentMonth == itemMonth
            }
            
            let expense = filterdItems.filter { $0.category?.isExpense == true }.map { $0.amount }.reduce(0, +)
            let income = filterdItems.filter { $0.category?.isExpense == false }.map { $0.amount }.reduce(0, +)
            let entry = SimpleEntry(date: Date(), expense: expense, income: income)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let expense: Double
    let income: Double
}

struct MoneyBookWidgetsEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Balance")
                .font(.title3)
                .padding([.leading, .trailing], 16)
                .padding(.top, 16)
                .padding(.bottom, 1)
            
            Spacer()

            Text("소득 \(entry.income.formatted())")
                .foregroundStyle(Color.customIndigo1)
                .font(.system(size: 12))
                .padding([.leading, .trailing], 4)
            Text("지출 \(entry.expense.formatted())")
                .foregroundStyle(Color.customOrange1)
                .font(.system(size: 12))
                .padding([.leading, .trailing], 4)

            Color.clear
                .frame(height: 20)
                .overlay {
                    GeometryReader { metrix in
                        HStack(spacing: 0) {
                            Color.customIndigo1
                                .frame(
                                    width: metrix.size.width * min(1.0, entry.income / (entry.expense + entry.income)))
                            Color.customOrange1
                        }
                    }
                }
        }
    }
}

struct MoneyBookWidgets: Widget {
    let kind: String = "MoneyBookWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MoneyBookWidgetsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct MoneyBookCircularWidgets: Widget {
    let kind: String = "MoneyBookCircularWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            let overExpense = entry.expense > entry.income

            let minValue = overExpense ? entry.income : entry.expense
            let maxValue = overExpense ? entry.expense : entry.income
            let current = (minValue / maxValue) * 100 * (overExpense ? -1 : 1)

            Gauge(
                value: current,
                in: (overExpense ? -100 : 0)...(overExpense ? 0 : 100),
                label: {
                    Image(systemName: "dollarsign")
                },
                currentValueLabel: { Text("\(Int(current))%") },
                minimumValueLabel: { Text(overExpense ? "-100" : "0") },
                maximumValueLabel: { Text(overExpense ? "0" : "100") }
            )
            .gaugeStyle(.accessoryCircular)
            .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.accessoryCircular])
    }
}

struct MoneyBookRectangularWidgets: Widget {
    let kind: String = "MoneyBookRectangularWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            let overExpense = entry.expense > entry.income

            let minValue = overExpense ? entry.income : entry.expense
            let maxValue = overExpense ? entry.expense : entry.income
            let current = (minValue / maxValue) * 100 * (overExpense ? -1 : 1)
            let remain = Int(maxValue - minValue)

            VStack(alignment: .leading) {
                Text("\(remain) \(overExpense ? "초과" : "남음")")

                Gauge(
                    value: current,
                    in: (overExpense ? -100 : 0)...(overExpense ? 0 : 100),
                    label: {
                        Image(systemName: "dollarsign")
                    }
                    //                },
                    //                currentValueLabel: { Text("\(Int(current))%") },
                    //                minimumValueLabel: { Text(overExpense ? "-100" : "0") },
                    //                maximumValueLabel: { Text(overExpense ? "0" : "100") }
                )
                .gaugeStyle(.accessoryLinear)
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    MoneyBookWidgets()
} timeline: {
    SimpleEntry(date: .now, expense: 200000, income: 450000)
    SimpleEntry(date: .now, expense: 450000, income: 200000)
}

#Preview(as: .accessoryCircular) {
    MoneyBookCircularWidgets()
} timeline: {
    SimpleEntry(date: .now, expense: 200000, income: 450000)
    SimpleEntry(date: .now, expense: 450000, income: 200000)
}

#Preview(as: .accessoryRectangular) {
    MoneyBookRectangularWidgets()
} timeline: {
    SimpleEntry(date: .now, expense: 200000, income: 450000)
    SimpleEntry(date: .now, expense: 450000, income: 200000)
}
