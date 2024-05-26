//
//  GroupManager.swift
//  MoneyBook
//
//  Created by Hoju Choi on 5/26/24.
//

import Foundation
import SwiftData

public class GroupManager {
    public static let shared = GroupManager()

    public var modelContext: ModelContext?

    private var currentGroupTitle: String?
    public var currentGroup: GroupCoreEntity? {
        return try? modelContext?
            .fetch(
                FetchDescriptor(
                    predicate: #Predicate<GroupCoreEntity> { group in
                        return group.title == (currentGroupTitle ?? "")
                    })
            )
            .first
    }

    private init() {
        self.currentGroupTitle = UserDefaults.standard.string(forKey: "currentGroupTitle")
    }

    public func setGroup(_ group: GroupCoreEntity) {
        let title = group.title
        UserDefaults.standard.set(title, forKey: "currentGroupTitle")
        self.currentGroupTitle = title
    }
}
