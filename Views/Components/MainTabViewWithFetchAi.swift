// MainTabViewWithFetchAi.swift
import SwiftUI

struct MainTabViewWithFetchAi: View {
    @State private var selectedTab = 2 // Start with FetchAi Stressors tab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(0)
            
            AddEntryView()
                .tabItem {
                    Label("Add Entry", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            FetchAiStressorsView()
                .tabItem {
                    Label("AI Insights", systemImage: "brain.head.profile")
                }
                .tag(2)
        }
    }
}