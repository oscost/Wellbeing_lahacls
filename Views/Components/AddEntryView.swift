import SwiftUI

struct AddEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: WellbeingStore
    @EnvironmentObject var healthData: HealthDataFetcher
    
    // Using current date directly instead of allowing selection
    private let currentDate = Date()
    @State private var mood = 5
    @State private var energy = 5
    @State private var dailyJournal = ""
    @State private var emotionalState = ""
    @State private var showingSavedConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date display (non-editable)
                    Section {
                        HStack {
                            Text(dateFormatter.string(from: currentDate))
                                .font(.headline)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Health data section
                    Section {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Today's Health Data")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            VStack(alignment: .leading, spacing: 8)  {
                                HealthDataRow(icon: "figure.walk", label: "Steps", value: "\(healthData.todaysData.steps)")
                                HealthDataRow(icon: "iphone", label: "Screen Time", value: "\(healthData.todaysData.screenTimeMinutes) min")
                                HealthDataRow(icon: "bed.double", label: "Sleep", value: String(format: "%.1f hrs", healthData.todaysData.sleepHours))
                                HealthDataRow(icon: "heart", label: "Heart Rate", value: "\(healthData.todaysData.heartRate) bpm")
                                HealthDataRow(icon: "flame", label: "Calories", value: "\(healthData.todaysData.caloriesBurned) kcal")
                                HealthDataRow(icon: "drop", label: "Water", value: "\(healthData.todaysData.waterIntake) ml")
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Mood section
                    Section {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("How was your day?")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            VStack(spacing: 20) {
                                // Mood slider
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Mood: \(mood)/10")
                                        .font(.subheadline)
                                        .bold()
                                    
                                    HStack {
                                        Text("😞")
                                            .font(.title2)
                                        
                                        Slider(value: Binding(
                                            get: { Double(mood) },
                                            set: { mood = Int($0) }
                                        ), in: 1...10, step: 1)
                                        
                                        Text("😄")
                                            .font(.title2)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        ForEach(1...10, id: \.self) { rating in
                                            Circle()
                                                .fill(rating == mood ? moodColor(for: rating) : Color.clear)
                                                .frame(width: 20, height: 20)
                                                .overlay(
                                                    Circle()
                                                        .stroke(moodColor(for: rating), lineWidth: 2)
                                                )
                                        }
                                    }
                                }
                                
                                // Energy slider
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Energy: \(energy)/10")
                                        .font(.subheadline)
                                        .bold()
                                    
                                    HStack {
                                        Text("🔋")
                                            .font(.title2)
                                        
                                        Slider(value: Binding(
                                            get: { Double(energy) },
                                            set: { energy = Int($0) }
                                        ), in: 1...10, step: 1)
                                        
                                        Text("⚡")
                                            .font(.title2)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        ForEach(1...10, id: \.self) { rating in
                                            Circle()
                                                .fill(rating == energy ? energyColor(for: rating) : Color.clear)
                                                .frame(width: 20, height: 20)
                                                .overlay(
                                                    Circle()
                                                        .stroke(energyColor(for: rating), lineWidth: 2)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Daily journal section
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Daily Activities")
                                .font(.headline)
                            
                            Text("What did you accomplish today? What didn't you get done?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $dailyJournal)
                                    .frame(minHeight: 150)
                                    .padding(4)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                
                                if dailyJournal.isEmpty {
                                    Text("Things I did today...\nThings I didn't finish...")
                                        .foregroundColor(.gray)
                                        .padding(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Emotional state section
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Emotional State")
                                .font(.headline)
                            
                            Text("Describe your emotions and feelings today")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $emotionalState)
                                    .frame(minHeight: 150)
                                    .padding(4)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                
                                if emotionalState.isEmpty {
                                    Text("I felt happy when...\nI was stressed about...\nI'm looking forward to...")
                                        .foregroundColor(.gray)
                                        .padding(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Save button
                    Button(action: {
                        saveEntry()
                        showingSavedConfirmation = true
                    }) {
                        Text("Save Entry")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.vertical)
                }
                .padding()
            }
            .navigationTitle("Today's Entry")
            .alert(isPresented: $showingSavedConfirmation) {
                Alert(
                    title: Text("Entry Saved"),
                    message: Text("Your journal entry has been saved."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func saveEntry() {
        let newEntry = WellbeingEntry(
            date: currentDate,
            mood: mood,
            energy: energy, // You'll need to add this to your WellbeingEntry model
            steps: healthData.todaysData.steps,
            screenTimeMinutes: healthData.todaysData.screenTimeMinutes,
            sleepHours: healthData.todaysData.sleepHours,
            heartRate: healthData.todaysData.heartRate,
            caloriesBurned: healthData.todaysData.caloriesBurned,
            waterIntake: healthData.todaysData.waterIntake,
            dailyJournal: dailyJournal,
            emotionalState: emotionalState // You'll need to add this to your WellbeingEntry model
        )
        store.addEntry(newEntry)
        
        // Reset fields or dismiss based on context
        if presentationMode.wrappedValue.isPresented {
            presentationMode.wrappedValue.dismiss()
        } else {
            // Just show confirmation and reset fields
            mood = 5
            energy = 5
            dailyJournal = ""
            emotionalState = ""
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    private func moodColor(for rating: Int) -> Color {
        switch rating {
        case 1...3:
            return .red
        case 4...6:
            return .orange
        case 7...8:
            return .blue
        case 9...10:
            return .green
        default:
            return .gray
        }
    }
    
    private func energyColor(for rating: Int) -> Color {
        switch rating {
        case 1...3:
            return .red
        case 4...6:
            return .yellow
        case 7...10:
            return .green
        default:
            return .gray
        }
    }
}

struct HealthDataRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
            Text(label)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
