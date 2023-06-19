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
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemEntity.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ItemEntity>
    private var groupedItems: [GroupedItem] {
        self.groupItems(Array(self.items))
    }
    
    struct GroupedItem {
        let date: Date
        var items: [ItemEntity]
    }
    private func groupItems(_ items: [ItemEntity]) -> [GroupedItem] {
        var result = [GroupedItem]()
        
        for item in items {
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
    
    @State var selectedDate: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    List {
                        ForEach(groupedItems, id: \.date) { group in
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
                            .onDelete(perform: deleteItems)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
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
                            Text("2023년 6월")
                            Image(systemName: "chevron.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 10)
                        }
                    }
                }
            }
            .toolbar(.visible, for: .navigationBar)
            .foregroundColor(.primary)
        }
    }
    
    private func changeDate() {
        
    }
    
    private func addItem() {
        withAnimation {
            let newItem = ItemEntity(context: viewContext)
            newItem.timestamp = Date()

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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

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
