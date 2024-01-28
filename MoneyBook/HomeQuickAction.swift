//
//  HomeQuickAction.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/28/24.
//

import Foundation

enum HomeQuickAction {
    case add

    init?(type: String) {
        if type == "add" {
            self = .add
        } else {
            return nil
        }
    }
}

class HomeQuickActionManager: ObservableObject {
    static let shared = HomeQuickActionManager()
    @Published var action: HomeQuickAction?
}
