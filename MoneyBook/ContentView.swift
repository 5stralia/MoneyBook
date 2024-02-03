//
//  ContentView.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/10.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "calendar.day.timeline.leading")
                }
                .toolbarBackground(.visible, for: .tabBar)

            ChartView()
                .tabItem {
                    Label("Chart", systemImage: "chart.pie")
                }
                .toolbarBackground(.visible, for: .tabBar)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(PersistenceController.preview.container)
    }
}
