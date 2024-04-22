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
                NavigationStack {
                    TimelineView()
                }
                .tabItem {
                    Label("Timeline", systemImage: "calendar.day.timeline.leading")
                }

                ChartView()
                    .tabItem {
                        Label("Chart", systemImage: "chart.pie")
                    }
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color(uiColor: .systemBackground), for: .tabBar)
        }
        .tint(Color.customOrange1)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(PersistenceController.preview.container)
    }
}
