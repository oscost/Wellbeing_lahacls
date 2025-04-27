// FetchAiService.swift
import Foundation
import Combine

// Models for Fetch.ai response
struct FetchRecommendation: Identifiable {
    var id = UUID()
    var target: String
    var recommendation: String
    var priority: String
    var actions: [String]
}

// Service to communicate with Fetch.ai backend
class FetchAiService: ObservableObject {
    // Published properties to share data with the UI
    @Published var analyzedStressors: [Stressor] = []
    @Published var recommendations: [FetchRecommendation] = []
    @Published var isAnalyzing: Bool = false
    @Published var lastAnalysisDate: Date?
    @Published var error: String?
    
    // Singleton instance
    static let shared = FetchAiService()
    
    // API endpoint - change this to your backend URL
    // For local development with a simulator, use localhost
    // For real device testing, use your computer's IP address on the local network
    private let backendURL = "http://localhost:8000"  // Change this to your actual backend URL
    
    // Analyze user data
    func analyzeUserData(entries: [WellbeingEntry]) {
        isAnalyzing = true
        error = nil
        
        // Convert entries to the format needed for the API
        let entriesData = entries.map { entry -> [String: Any] in
            return [
                "date": ISO8601DateFormatter().string(from: entry.date),
                "mood": entry.mood,
                "energy": entry.energy,
                "steps": entry.steps,
                "screenTimeMinutes": entry.screenTimeMinutes,
                "sleepHours": entry.sleepHours,
                "heartRate": entry.heartRate,
                "caloriesBurned": entry.caloriesBurned,
                "waterIntake": entry.waterIntake,
                "dailyJournal": entry.dailyJournal,
                "emotionalState": entry.emotionalState
            ]
        }
        
        // Create request body
        let requestBody: [String: Any] = ["entries": entriesData]
        
        // Create URL request
        guard let url = URL(string: "\(backendURL)/analyze") else {
            self.isAnalyzing = false
            self.error = "Invalid backend URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            self.isAnalyzing = false
            self.error = "Error serializing request: \(error.localizedDescription)"
            return
        }
        
        // Send request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                
                if let error = error {
                    self?.error = "Request failed: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received from server"
                    return
                }
                
                do {
                    // Parse the response
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        // Parse last analysis date
                        if let timestamp = json["analysis_timestamp"] as? String {
                            let formatter = ISO8601DateFormatter()
                            self?.lastAnalysisDate = formatter.date(from: timestamp)
                        }
                        
                        // Handle stressors
                        if let stressorsData = json["stressors"] as? [[String: Any]] {
                            let stressors = stressorsData.compactMap { stressorData -> Stressor? in
                                guard let name = stressorData["name"] as? String,
                                      let level = stressorData["level"] as? Int,
                                      let description = stressorData["description"] as? String else {
                                    return nil
                                }
                                
                                // Get the impact or use a default
                                let impact = stressorData["impact"] as? String ?? "May affect your wellbeing"
                                
                                // Create recommendation strings
                                var recommendations: [String] = []
                                
                                // We'll fill these from the recommendations section later
                                
                                return Stressor(
                                    id: UUID(),  // Generate a new ID
                                    name: name,
                                    level: level,
                                    description: description,
                                    recommendations: recommendations
                                )
                            }
                            
                            self?.analyzedStressors = stressors
                        }
                        
                        // Handle recommendations
                        if let recommendationsData = json["recommendations"] as? [[String: Any]] {
                            let recommendations = recommendationsData.compactMap { recData -> FetchRecommendation? in
                                guard let target = recData["target"] as? String,
                                      let recommendation = recData["recommendation"] as? String,
                                      let priority = recData["priority"] as? String,
                                      let actions = recData["actions"] as? [String] else {
                                    return nil
                                }
                                
                                return FetchRecommendation(
                                    target: target,
                                    recommendation: recommendation,
                                    priority: priority,
                                    actions: actions
                                )
                            }
                            
                            self?.recommendations = recommendations
                            
                            // Now update the stressors with relevant recommendations
                            if let stressors = self?.analyzedStressors {
                                var updatedStressors = stressors
                                
                                for (index, stressor) in stressors.enumerated() {
                                    // Find matching recommendations
                                    let matchingRecs = recommendations.filter { rec in
                                        rec.target.contains(stressor.name) ||
                                        stressor.name.contains(rec.target)
                                    }
                                    
                                    // Extract action items
                                    let recActions = matchingRecs.flatMap { $0.actions }
                                    
                                    // Update stressor
                                    if !recActions.isEmpty {
                                        updatedStressors[index].recommendations = recActions
                                    }
                                }
                                
                                self?.analyzedStressors = updatedStressors
                            }
                        }
                    }
                } catch {
                    self?.error = "Error parsing response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    // For testing: Use sample data from the backend
    func fetchSampleAnalysis() {
        isAnalyzing = true
        error = nil
        
        guard let url = URL(string: "\(backendURL)/sample") else {
            self.isAnalyzing = false
            self.error = "Invalid backend URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                
                if let error = error {
                    self?.error = "Request failed: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received from server"
                    return
                }
                
                do {
                    // Use the same parsing logic as the analyze method
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        // Parse timestamp
                        if let timestamp = json["analysis_timestamp"] as? String {
                            let formatter = ISO8601DateFormatter()
                            self?.lastAnalysisDate = formatter.date(from: timestamp)
                        }
                        
                        // Parse stressors
                        if let stressorsData = json["stressors"] as? [[String: Any]] {
                            let stressors = stressorsData.compactMap { stressorData -> Stressor? in
                                guard let name = stressorData["name"] as? String,
                                      let level = stressorData["level"] as? Int,
                                      let description = stressorData["description"] as? String else {
                                    return nil
                                }
                                
                                // Get the impact or use a default
                                let impact = stressorData["impact"] as? String ?? "May affect your wellbeing"
                                
                                return Stressor(
                                    id: UUID(),  // Generate a new ID
                                    name: name,
                                    level: level,
                                    description: description,
                                    recommendations: []
                                )
                            }
                            
                            self?.analyzedStressors = stressors
                        }
                        
                        // Parse recommendations
                        if let recommendationsData = json["recommendations"] as? [[String: Any]] {
                            let recommendations = recommendationsData.compactMap { recData -> FetchRecommendation? in
                                guard let target = recData["target"] as? String,
                                      let recommendation = recData["recommendation"] as? String,
                                      let priority = recData["priority"] as? String,
                                      let actions = recData["actions"] as? [String] else {
                                    return nil
                                }
                                
                                return FetchRecommendation(
                                    target: target,
                                    recommendation: recommendation,
                                    priority: priority,
                                    actions: actions
                                )
                            }
                            
                            self?.recommendations = recommendations
                            
                            // Update stressors with relevant recommendations
                            if let stressors = self?.analyzedStressors {
                                var updatedStressors = stressors
                                
                                for (index, stressor) in stressors.enumerated() {
                                    // Find matching recommendations
                                    let matchingRecs = recommendations.filter { rec in
                                        rec.target.contains(stressor.name) ||
                                        stressor.name.contains(rec.target)
                                    }
                                    
                                    // Extract action items
                                    let recActions = matchingRecs.flatMap { $0.actions }
                                    
                                    // Update stressor
                                    if !recActions.isEmpty {
                                        updatedStressors[index].recommendations = recActions
                                    }
                                }
                                
                                self?.analyzedStressors = updatedStressors
                            }
                        }
                    }
                } catch {
                    self?.error = "Error parsing response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
