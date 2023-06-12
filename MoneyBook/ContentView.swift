//
//  ContentView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/10.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "calendar.day.timeline.leading")
                }
                .toolbarBackground(.visible, for: .tabBar)
            
            Color.orange
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            Color.indigo
                .tabItem {
                    Label("Chart", systemImage: "chart.pie")
                }
        }
        .tint(.primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
