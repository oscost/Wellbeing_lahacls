// HealthDataFetcher.swift
import Foundation
import Combine

class HealthDataFetcher: ObservableObject {
    @Published var todaysData: HealthMetrics = HealthMetrics()
    
    // This would normally connect to health data sources, but we're using simulated data
    func fetchTodaysData() {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.todaysData = HealthMetrics(
                steps: Int.random(in: 3000...15000),
                screenTimeMinutes: Int.random(in: 60...360),
                sleepHours: Double.random(in: 5.0...9.0).rounded(to: 1),
                heartRate: Int.random(in: 60...100),
                caloriesBurned: Int.random(in: 1500...3000),
                waterIntake: Int.random(in: 1000...3000)
            )
        }
    }
    
    init() {
        fetchTodaysData()
    }
}

struct HealthMetrics {
    var steps: Int = 0
    var screenTimeMinutes: Int = 0
    var sleepHours: Double = 0.0
    var heartRate: Int = 0
    var caloriesBurned: Int = 0
    var waterIntake: Int = 0
}
