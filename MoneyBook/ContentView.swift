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
            Group {
                TimelineView()
                    .tabItem {
                        Label("Timeline", systemImage: "calendar.day.timeline.leading")
                    }

                ChartView()
                    .tabItem {
                        Label("Chart", systemImage: "chart.pie")
                    }
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color(uiColor: .systemGray6), for: .tabBar)
        }
        .tint(Color.primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(PersistenceController.preview.container)
    }
}
