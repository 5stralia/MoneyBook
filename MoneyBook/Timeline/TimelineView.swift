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
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(groupedItems, id: \.date) { group in
                        HStack {
                            Spacer()
                            TimelineDateView(date: group.date)
                            Spacer()
                        }
                        ForEach(group.items, id: \.id) { item in
                            if item.amount > 0 {
                                HStack {
                                    TimelineItemView(title: item.title, imageName: "carrot", categoryName: item.category, amount: item.amount)
                                    Spacer(minLength: 80)
                                }
                                .listRowSeparator(.hidden)
                            } else {
                                HStack {
                                    Spacer(minLength: 80)
                                    TimelineItemView(title: item.title, imageName: "carrot", categoryName: item.category, amount: item.amount)
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                    
                    Color.clear
                        .frame(height: 37)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                
                TimelineSummaryValueView(paid: 300000, earning: 500000)
                    .frame(height: 37)
            }
            
            TimelineSummaryView(totalValue: 700000)
        }
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
