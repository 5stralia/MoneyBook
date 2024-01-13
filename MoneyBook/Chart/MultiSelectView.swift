//
//  MultiSelectView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 12/10/23.
//

import SwiftUI

struct SelectionItem: Identifiable, Hashable {
    let name: String
    var isSelected: Bool
    let id = UUID()
}

struct MultiSelectView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var items: [SelectionItem]
    @State var selection: [String]

    init(items: [SelectionItem], selection: State<[String]>) {
        self._items = State(initialValue: items)
        self._selection = selection
    }

    var body: some View {
        NavigationStack {
            List(self.$items) { $item in
                HStack {
                    let checkmark = Image(systemName: "checkmark")

                    if item.isSelected { checkmark } else { checkmark.hidden() }
                    Text(item.name)
                }
                .onTapGesture {
                    item.isSelected.toggle()
                }
            }
            .toolbar {
                Button(
                    action: {
                        self.selection = items.filter({ $0.isSelected }).map({ $0.name })
                        dismiss()
                    },
                    label: {
                        Text("done")
                    })
            }
        }

    }
}

#Preview {
    MultiSelectView(
        items: [
            SelectionItem(name: "one", isSelected: false),
            SelectionItem(name: "two", isSelected: true),
            SelectionItem(name: "three", isSelected: true),
            SelectionItem(name: "four", isSelected: false)
        ],
        selection: State(initialValue: [])
    )
}
