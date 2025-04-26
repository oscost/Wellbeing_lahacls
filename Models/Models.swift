import Foundation

struct WellbeingEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var mood: Int // 1-10 scale
    var dailyJournal: String // Free response section for describing the day
    
    static func mockData() -> [WellbeingEntry] {
        let calendar = Calendar.current
        var mockEntries: [WellbeingEntry] = []
        
        // Create entries for the past week
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let entry = WellbeingEntry(
                date: date,
                mood: Int.random(in: 1...10),
                dailyJournal: "Today I felt pretty good. Went for a walk in the park and called my friend. Made dinner at home and watched a movie."
            )
            mockEntries.append(entry)
        }
        
        return mockEntries
    }
}
