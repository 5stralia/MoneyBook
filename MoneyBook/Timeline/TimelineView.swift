//
//  TimelineView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/11.
//

import CoreData
import SwiftUI

struct TimelineView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemCoreEntity.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ItemCoreEntity>
    
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
        
        return result
    }
    private var earning: Double {
        self.items.filter { $0.amount > 0 }.map { $0.amount }.reduce(0, +)
    }
    private var paid: Double {
        self.items.filter { $0.amount < 0 }.map { $0.amount }.reduce(0, +)
    }
    
    @State var year: Int = Calendar.current.component(.year, from: Date())
    @State var month: Int = Calendar.current.component(.month, from: Date())
    
    @State var isHiddenPicker: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottom) {
                        List {
                            ForEach(self.groupItems(Array(self.items), year: year, month: month), id: \.date) { group in
                                HStack {
                                    Spacer()
                                    TimelineDateView(date: group.date)
                                    Spacer()
                                }
                                .listRowSeparator(.hidden)
                                ForEach(group.items, id: \.id) { item in
                                    if item.amount > 0 {
                                        HStack {
                                            Spacer(minLength: 80)
                                            TimelineItemView(title: item.title, imageName: "carrot", categoryName: item.category, amount: item.amount)
                                        }
                                        .listRowSeparator(.hidden)
                                    } else {
                                        HStack {
                                            TimelineItemView(title: item.title, imageName: "carrot", categoryName: item.category, amount: item.amount)
                                            Spacer(minLength: 80)
                                        }
                                        .listRowSeparator(.hidden)
                                    }
                                }
                                .onDelete(perform: { indexSet in
                                    let deletedItems = indexSet.map { group.items[$0] }
                                    self.deleteItems(items: deletedItems)
                                })
                            }
                            
                            Color.clear
                                .frame(height: 37)
                                .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        
                        TimelineSummaryValueView(paid: paid, earning: earning)
                            .frame(height: 37)
                    }
                    
                    TimelineSummaryView(paid: paid, earning: earning)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    NavigationLink {
                        AppendingItemView()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        Text("This is Settings")
                    } label: {
                        Label("Open Settings", systemImage: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Button(action: changeDate) {
                        HStack(spacing: 5) {
                            Text(verbatim: "\(year)년 \(month)월")
                            Image(systemName: "chevron.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 10)
                        }
                    }
                }
            }
            .toolbar(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.primary)
        }
    }
    
    private func changeDate() {
        withAnimation {
            self.isHiddenPicker.toggle()
        }
    }
    
    private func deleteItems(items: [ItemCoreEntity]) {
        withAnimation {
            items.forEach { viewContext.delete($0) }

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
