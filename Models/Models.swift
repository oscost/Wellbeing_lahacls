// Models.swift
import Foundation

struct WellbeingEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var mood: Int // 1-10 scale
    var steps: Int
    var screenTimeMinutes: Int
    var sleepHours: Double
    var heartRate: Int
    var caloriesBurned: Int
    var waterIntake: Int // in ml
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
                steps: Int.random(in: 3000...15000),
                screenTimeMinutes: Int.random(in: 60...360),
                sleepHours: Double.random(in: 5.0...9.0).rounded(to: 1),
                heartRate: Int.random(in: 60...100),
                caloriesBurned: Int.random(in: 1500...3000),
                waterIntake: Int.random(in: 1000...3000),
                dailyJournal: "Today I felt pretty good. Went for a walk in the park and called my friend. Made dinner at home and watched a movie."
            )
            mockEntries.append(entry)
        }
        
        return mockEntries
    }
}

// Helper extension for rounding doubles
extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
