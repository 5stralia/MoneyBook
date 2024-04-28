//
//  MoneyBookWidgets.swift
//  MoneyBookWidgets
//
//  Created by Hoju Choi on 12/14/23.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), expense: 200000, income: 450000)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), expense: 200000, income: 450000)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, expense: 200000, income: 450000)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
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

            HStack {
                Spacer()
                Text("200,000 남음")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.gray)
            }
            .padding([.leading, .trailing], 16)

            Spacer()

            Text("소득 450,000")
                .foregroundStyle(Color.customIndigo1)
                .font(.system(size: 12))
                .padding([.leading, .trailing], 4)
            Text("지출 200,000")
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
