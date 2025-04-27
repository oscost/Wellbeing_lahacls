import Foundation

struct Stressor: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var level: Int // 1-10 scale
    var description: String
    var recommendations: [String]
    
    static func mockData() -> [Stressor] {
        return [
            Stressor(
                name: "Work Pressure",
                level: 8,
                description: "Deadlines and work expectations are causing significant stress",
                recommendations: [
                    "Break large tasks into smaller, manageable chunks",
                    "Practice time-blocking for focused work",
                    "Take short breaks every 45-60 minutes",
                    "Communicate with your manager about your workload"
                ]
            ),
            Stressor(
                name: "Sleep Issues",
                level: 7,
                description: "Difficulty falling asleep or staying asleep is affecting your energy levels",
                recommendations: [
                    "Establish a consistent sleep schedule",
                    "Create a relaxing bedtime routine",
                    "Limit screen time 1 hour before bed",
                    "Keep your bedroom cool, dark, and quiet",
                    "Consider meditation or gentle yoga before bed"
                ]
            ),
            Stressor(
                name: "Relationship Tension",
                level: 5,
                description: "Ongoing issues in personal relationships are causing emotional strain",
                recommendations: [
                    "Practice active listening",
                    "Schedule quality time with loved ones",
                    "Use I statements when discussing issues",
                    "Consider seeking support from a relationship counselor"
                ]
            ),
            Stressor(
                name: "Financial Worry",
                level: 6,
                description: "Concerns about money and financial stability",
                recommendations: [
                    "Create or revisit your monthly budget",
                    "Identify non-essential expenses that could be reduced",
                    "Set up automated savings, even for small amounts",
                    "Consider speaking with a financial advisor"
                ]
            ),
            Stressor(
                name: "Digital Overload",
                level: 7,
                description: "Constant connectivity and notifications are creating anxiety",
                recommendations: [
                    "Set specific times to check emails and social media",
                    "Use 'Do Not Disturb' mode during focus time",
                    "Delete unnecessary apps from your phone",
                    "Try a digital detox for one day per week"
                ]
            )
        ]
    }
}
