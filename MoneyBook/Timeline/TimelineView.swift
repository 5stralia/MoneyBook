//
//  TimelineView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/11.
//

import SwiftData
import SwiftUI

struct TimelineView: View {
    @Namespace var bottomID

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var homeQuickActionManager: HomeQuickActionManager
    @Environment(\.scenePhase) var scenePhase

    @Query var items: [ItemCoreEntity]
    @Query var categories: [CategoryCoreEntity]

    @State var editing: ItemCoreEntity?

    struct GroupedItem {
        let date: Date
        var items: [ItemCoreEntity]
    }
    private func groupItems(_ items: [ItemCoreEntity], year: Int, month: Int) -> [GroupedItem] {
        var result = [GroupedItem]()

        let filteredItems = items.filter { item in
            let itemYear = Calendar.current.component(.year, from: item.timestamp)
            let itemMonth = Calendar.current.component(.month, from: item.timestamp)

            return year == itemYear && month == itemMonth
        }
        for item in filteredItems {
            if let index = result.firstIndex(where: { finding in
                finding.date.isEqualDateOnly(item.timestamp)
            }) {
                result[index].items.append(item)
            } else {
                result.append(GroupedItem(date: item.timestamp, items: [item]))
            }
        }

        result.sort(using: KeyPathComparator(\.date))

        return result
    }
    private var earning: Double {
        self.items.filter {
            !($0.category?.isExpense ?? true) &&
            $0.timestamp.getYear() == self.year &&
            $0.timestamp.getMonth() == self.month
        }
        .map(\.amount)
        .reduce(0, +)
    }
    private var paid: Double {
        self.items.filter {
            ($0.category?.isExpense ?? false) &&
            $0.timestamp.getYear() == self.year &&
            $0.timestamp.getMonth() == self.month
        }
        .map(\.amount)
        .reduce(0, +)
    }

    @State var year: Int = Calendar.current.component(.year, from: Date())
    @State var month: Int = Calendar.current.component(.month, from: Date())

    @State var isHiddenPicker: Bool = true

    @State private var isPresentedAppending: Bool = false
    @State private var edittingItem: ItemCoreEntity?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Header(
                    topText: "Timeline",
                    title: "\(self.year).\(self.month)",
                    action: {
                        self.isHiddenPicker.toggle()
                    }
                )

                TimelineSummaryView(paid: paid, earning: earning)

                ZStack(alignment: .bottomTrailing) {
                    ZStack(alignment: .topLeading) {
                        ScrollViewReader { proxy in
                            let groups = self.groupItems(Array(self.items), year: year, month: month)
                            List {
                                ForEach(groups, id: \.date) {
                                    group in
                                    HStack {
                                        Spacer()
                                        TimelineDateView(date: group.date)
                                        Spacer()
                                    }
                                    ForEach(group.items, id: \.id) { item in
                                        Button {
                                            editing = item
                                        } label: {
                                            if item.category?.isExpense ?? true {
                                                HStack {
                                                    Spacer(minLength: 80)
                                                    TimelineItemView(
                                                        title: item.title,
                                                        categoryName: item.category?.title ?? "",
                                                        amount: item.amount,
                                                        isExpense: item.category?.isExpense ?? true
                                                    )
                                                }
                                            } else {
                                                HStack {
                                                    TimelineItemView(
                                                        title: item.title,
                                                        categoryName: item.category?.title ?? "",
                                                        amount: item.amount,
                                                        isExpense: item.category?.isExpense ?? false
                                                    )
                                                    Spacer(minLength: 80)
                                                }
                                            }
                                        }
                                    }
                                    .onDelete(perform: { indexSet in
                                        let deletedItems = indexSet.map { group.items[$0] }
                                        self.deleteItems(items: deletedItems)
                                    })
                                }
                                .listRowSeparator(.hidden)

                                Color.clear
                                    .frame(height: 37)
                                    .listRowSeparator(.hidden)
                                    .id(bottomID)
                            }
                            .onReceive(
                                self.items.publisher,
                                perform: { _ in
                                    proxy.scrollTo(bottomID)
                                }
                            )
                            .listStyle(.plain)
                        }

                        TimelineSummaryView2(
                            total: (earning - paid).formatted(),
                            income: earning.formatted(),
                            expense: paid.formatted()
                        )
                        .padding(.top, 8)
                        .padding([.leading, .trailing], 20)
                    }

                    NavigationLink {
                        AppendingItemView2()
                    } label: {
                        TimelineAddButton()
                            .padding([.trailing, .bottom], 25)
                    }
                }
            }

            if !isHiddenPicker {
                VStack(spacing: 5) {
                    HStack {
                        Picker("Year", selection: $year) {
                            ForEach((2000...2100), id: \.self) { i in
                                Text(String(i))
                            }
                        }
                        .pickerStyle(.wheel)
                        Picker("Month", selection: $month) {
                            ForEach((1...12), id: \.self) { i in
                                Text(String(i))
                            }
                        }
                        .pickerStyle(.wheel)
                    }

                    Button {
                        withAnimation {
                            self.isHiddenPicker.toggle()
                        }
                    } label: {
                        Text("Done")
                    }

                }
                .padding(.bottom, 32)
                .background(.background)
                .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
                .shadow(radius: 8)
            }
        }
        .navigationDestination(
            item: $editing,
            destination: { item in
                AppendingItemView2(item: item)
            }
        )
        .onChange(of: scenePhase) { _, new in
            switch new {
            case .active:
                self.quickAction()
            case .background,
                .inactive:
                break
            @unknown default:
                fatalError()
            }
        }
        .toolbar(.visible, for: .tabBar)
    }

    private func quickAction() {
        guard let action = homeQuickActionManager.action else { return }

        switch action {
        case .add:
            self.isPresentedAppending = true
        }

        homeQuickActionManager.action = nil
    }

    private func changeDate() {
        withAnimation {
            self.isHiddenPicker.toggle()
        }
    }

    private func deleteItems(items: [ItemCoreEntity]) {
        withAnimation {
            items.forEach { item in
                self.modelContext.delete(item)
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
            .modelContainer(PersistenceController.preview.container)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect, byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
