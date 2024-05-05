//
//  SettingView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 5/4/24.
//

import SwiftData
import SwiftUI

private enum SettingSection: CaseIterable, Identifiable {
    static var allCases: [SettingSection] {
        return [
            .data([.export, .import, .deleteAll])
        ]
    }
    
    case data([SettingItem])
    
    var title: String {
        switch self {
        case .data:
            return "Data".localized
        }
    }
    
    var items: [SettingItem] {
        switch self {
        case .data(let array):
            return array
        }
    }
    
    var id: String { title }
}

private enum SettingItem: CaseIterable, Identifiable {
    case export
    case `import`
    case deleteAll
    
    var title: String {
        switch self {
        case .export:
            return "Export".localized
        case .import:
            return "Import".localized
        case .deleteAll:
            return "Delete All".localized
        }
    }
    
    var id: String { title }
}

struct SettingView: View {
    @Environment(\.modelContext) var modelContext
    @State var isFileImporterPreseneted: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(SettingSection.allCases) { item in
                    SettingSectionHeader(title: item.title)
                    
                    ForEach(item.items) { subItem in
                        if subItem == .export {
                            ShareLink(item: createCSV()) {
                                SettingItemView(imageSystemName: "dog", title: subItem.title)
                            }
                        } else {
                            Button {
                                performAction(subItem)
                            } label: {
                                SettingItemView(imageSystemName: "dog", title: subItem.title)
                            }
                        }
                    }
                }
            }
        }
        .fileImporter(isPresented: $isFileImporterPreseneted, allowedContentTypes: [.commaSeparatedText]) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else { return }
                openCSV(url: url)
            case .failure(let failure):
                MyLogger.error(failure.localizedDescription)
            }
        }
    }
    
    private func performAction(_ item: SettingItem) {
        switch item {
        case .export:
            break
        case .import:
            isFileImporterPreseneted = true
        case .deleteAll:
            deleteAllData()
        }
    }
    
    private func createCSV() -> URL {
        do {
            let items = try modelContext.fetch(FetchDescriptor<ItemCoreEntity>())
            
            let rows = try items.map { item -> String in
                guard let category = item.category,
                      let group = category.group
                else {
                    throw NSError(domain: "카테고리 또는 그룹 정보가 유실됨", code: -1)
                }
                
                return [
                    group.title,
                    group.createdDate.formatted(.iso8601),
                    category.title,
                    category.isExpense ? "1" : "0",
                    item.title,
                    String(item.amount),
                    item.timestamp.formatted(.iso8601),
                    item.note
                ]
                    .joined(separator: ",")
            }
                .joined(separator: "\n")
            
            let contents = "group_title,group_created,category_title,category_isExpese,title,amount,timestamp,note\n" + rows
            
            let filePath = try FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = filePath.appending(path: "moneybook.csv")
            
            try contents.write(to: fileURL, atomically: true, encoding: .utf8)
            
            return fileURL
        } catch let error {
            MyLogger.error(error.localizedDescription)
//            fatalError()
            return URL(filePath: "temp.csv")
        }
    }

    private func openCSV(url: URL) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            
            let groups = try modelContext.fetch(FetchDescriptor<GroupCoreEntity>())
            let categories = try modelContext.fetch(FetchDescriptor<CategoryCoreEntity>())
            
            let rows = content.components(separatedBy: .newlines).filter({ !$0.isEmpty })
            for row in rows[1...] {
                let cols = row.split(separator: ",", omittingEmptySubsequences: false)
                
                let groupTitle = cols[0]
                let groupCreated = cols[1]
                let categoryTitle = cols[2]
                let categoryIsExpense = cols[3]
                let title = cols[4]
                let amount = cols[5]
                let timestamp = cols[6]
                let note = cols[7]
                
                let group: GroupCoreEntity
                if let _group = groups.first(where: { $0.title == groupTitle }) {
                    group = _group
                } else {
                    let createdDate = try Date(groupCreated, strategy: .iso8601)
                    let newGroup = GroupCoreEntity(title: String(groupTitle), createdDate: createdDate)
                    modelContext.insert(newGroup)
                    
                    group = newGroup
                }
                
                let category: CategoryCoreEntity
                if let _category = group.categories?.first(where: { $0.title == categoryTitle }) {
                    category = _category
                } else {
                    let newCategory = CategoryCoreEntity(title: String(categoryTitle), isExpense: categoryIsExpense == "1")
                    newCategory.group = group
                    modelContext.insert(newCategory)
                    
                    category = newCategory
                }
                
                let newItem = ItemCoreEntity(amount: Double(amount) ?? 0, note: String(note), timestamp: try Date(timestamp, strategy: .iso8601), title: String(title) + "_added")
                newItem.category = category
                modelContext.insert(newItem)
            }
        } catch let error {
            MyLogger.error(error.localizedDescription)
        }
    }
    
    private func deleteAllData() {
        do {
            try modelContext.delete(model: ItemCoreEntity.self)
            try modelContext.delete(model: CategoryCoreEntity.self)
            try modelContext.delete(model: GroupCoreEntity.self)
        } catch let error {
            MyLogger.error(error.localizedDescription)
        }
    }
}

#Preview {
    SettingView()
        .modelContainer(PersistenceController.preview.container)
}
