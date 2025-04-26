import SwiftUI

@main
struct WellbeingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(WellbeingStore())
                .environmentObject(HealthDataFetcher())
        }
    }
}
