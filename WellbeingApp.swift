import SwiftUI

@main
struct WellbeingApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(WellbeingStore())
                .environmentObject(HealthDataFetcher())
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 2 // Start with Stressors tab
    
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
            
            StressorsView()
                .tabItem {
                    Label("Stressors", systemImage: "brain.head.profile")
                }
                .tag(2)
        }
    }
}
