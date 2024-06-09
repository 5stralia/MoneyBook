//
//  AppendingItemDateInputView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 4/27/24.
//

import SwiftUI

struct AppendingItemDateInputView: View {
    @Binding var isExpense: Bool
    @Binding var selected: Date

    var body: some View {
        ZStack(alignment: .center) {
            (isExpense ? Color.customOrange1 : Color.customIndigo1)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))

            VStack(spacing: 0) {
                MDatePicker(selected: $selected)
                    .padding(.bottom, 8)

                DatePicker("", selection: $selected, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.compact)
                    .background((isExpense ? Color.customOrange1 : Color.customIndigo1).colorInvert())
                    .tint(Color.black)
                    .colorMultiply(Color.white)
                    .colorInvert()
                    .padding([.leading, .trailing], 20)

                Spacer()
            }
            .padding(.top, 20)
            .padding([.leading, .trailing], 8)
        }
    }
}

struct MDatePicker: View {
    @Binding var selected: Date

    @State var showingDate: Date = Date()

    var body: some View {
        VStack(spacing: 0) {
            MDatePickerHeader(
                showingDate: $showingDate,
                prevAction: {
                    guard let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: showingDate) else {
                        return
                    }
                    showingDate = prevMonth
                },
                nextAction: {
                    guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: showingDate) else {
                        return
                    }
                    showingDate = nextMonth
                }
            )
            .padding([.leading, .trailing], 20)
            .padding(.bottom, 8)

            MDatePickerCalendar(showingDate: $showingDate, selected: $selected)
                .padding([.leading, .trailing], 20)
        }
        .foregroundStyle(.white)
    }
}

private struct MDatePickerHeader: View {
    @Binding var showingDate: Date
    var prevAction: () -> Void
    var nextAction: () -> Void

    private static var yearMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY. MM."
        return formatter
    }()

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: MDatePickerHeader.yearMonthFormatter.string(from: showingDate))
                .font(.Pretendard(size: 20, weight: .bold))

            Spacer()

            HStack(spacing: 0) {
                Button {
                    prevAction()
                } label: {
                    Image(systemName: "arrowtriangle.backward.fill")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .padding(.all, 15)
                }

                Button {
                    nextAction()
                } label: {
                    Image(systemName: "arrowtriangle.right.fill")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .padding(.all, 15)
                }
            }
        }
    }
}

struct MDatePickerCalendar: View {
    @Binding var showingDate: Date
    @Binding var selected: Date

    var remainders: [Int] = [6, 0, 1, 2, 3, 4, 5]

    var firstWeekDay: Int {
        let componenets = Calendar.current.dateComponents([.year, .month], from: showingDate)
        guard let firstDay = Calendar.current.date(from: componenets) else { return -1 }
        return Calendar.current.component(.weekday, from: firstDay)
    }

    var remainder: Int {
        guard firstWeekDay > 0 else { return -1 }
        return remainders[firstWeekDay - 1]
    }

    var body: some View {
        GridLayout(horizontalSpacing: 0, verticalSpacing: 0) {
            MDatePickerCalendarDayOfWeekLabel()

            let endDate = showingDate.endDateOfMonth.getDay() + 1
            StrideForEach(from: 1 - remainder, to: 43 - remainder, by: 7) { i in
                let days = (i..<min((i + 7), (43 - remainder))).map { day in
                    if day < 1 {
                        return MDatePickerCalendarWeekLabelType.empty
                    } else if day >= endDate {
                        return MDatePickerCalendarWeekLabelType.empty
                    } else {
                        return MDatePickerCalendarWeekLabelType.day(day)
                    }
                }
                MDatePickerCalendarWeekLabel(days: days, showingDate: $showingDate, selected: $selected)
            }
        }
    }
}

struct StrideForEach<Content>: View where Content: View {
    let from: Int
    let to: Int
    let by: Int
    @ViewBuilder let content: (Int) -> Content

    var body: some View {
        ForEach(Array(stride(from: from, to: to, by: by)), id: \.self) { i in
            content(i)
        }
    }
}

struct MDatePickerCalendarDayOfWeekLabel: View {
    private static let daysOfWeek: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        GridRow {
            ForEach(MDatePickerCalendarDayOfWeekLabel.daysOfWeek, id: \.self) { dayOfWeek in
                Text(LocalizedStringKey(dayOfWeek))
                    .font(.Pretendard(size: 10, weight: .semiBold))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

enum MDatePickerCalendarWeekLabelType: Identifiable, Equatable {
    case empty
    case day(Int)

    var id: String {
        switch self {
        case .empty:
            return UUID().uuidString
        case .day(let value):
            return String(value)
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.day(let lValue), .day(let rValue)):
            return lValue == rValue
        default:
            return false
        }
    }
}
struct MDatePickerCalendarWeekLabel: View {
    let days: [MDatePickerCalendarWeekLabelType]
    @Binding var showingDate: Date
    @Binding var selected: Date

    var body: some View {
        GridRow {
            ForEach(days) { day in
                switch day {
                case .empty:
                    Circle().foregroundStyle(.clear)
                case .day(let value):
                    MDatePickerCalendarDayLabel(day: value, showingDate: $showingDate, selected: $selected)
                }
            }
        }
    }
}

struct MDatePickerCalendarDayLabel: View {
    var day: Int
    @Binding var showingDate: Date
    @Binding var selected: Date

    var isSelected: Bool {
        return showingDate.getYear() == selected.getYear() && showingDate.getMonth() == selected.getMonth()
            && day == selected.getDay()
    }

    var body: some View {
        Button {
            let componenets = DateComponents(year: showingDate.getYear(), month: showingDate.getMonth(), day: day)
            guard let selection = Calendar.current.date(from: componenets) else { return }
            selected = selection
        } label: {
            ZStack {
                Circle().foregroundStyle(isSelected ? Color.dynamicWhite : .clear)

                Text(verbatim: "\(day)")
                    .font(.Pretendard(size: 19, weight: .semiBold))
                    .foregroundStyle(isSelected ? Color.dynamicBlack : Color.dynamicWhite)
                    .padding(.all, 12)
            }
        }
    }
}

#Preview {
    AppendingItemDateInputView(isExpense: .constant(false), selected: .constant(Date()))
}
