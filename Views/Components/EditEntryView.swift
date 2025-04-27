import SwiftUI

struct EditEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: WellbeingStore
    
    let entry: WellbeingEntry
    
    @State private var date: Date
    @State private var mood: Int
    @State private var energy: Int
    @State private var dailyJournal: String
    @State private var emotionalState: String
    
    init(entry: WellbeingEntry) {
        self.entry = entry
        _date = State(initialValue: entry.date)
        _mood = State(initialValue: entry.mood)
        _energy = State(initialValue: entry.energy)
        _dailyJournal = State(initialValue: entry.dailyJournal)
        _emotionalState = State(initialValue: entry.emotionalState)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date section
                    VStack {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    // Health data section (read-only)
                    VStack {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Health Data (Auto-collected)")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HealthDataRow(icon: "figure.walk", label: "Steps", value: "\(entry.steps)")
                                HealthDataRow(icon: "iphone", label: "Screen Time", value: "\(entry.screenTimeMinutes) min")
                                HealthDataRow(icon: "bed.double", label: "Sleep", value: String(format: "%.1f hrs", entry.sleepHours))
                                HealthDataRow(icon: "heart", label: "Heart Rate", value: "\(entry.heartRate) bpm")
                                HealthDataRow(icon: "flame", label: "Calories", value: "\(entry.caloriesBurned) kcal")
                                HealthDataRow(icon: "drop", label: "Water", value: "\(entry.waterIntake) ml")
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Mood and Energy section
                    VStack {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("How was your day?")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
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
                            
                            Divider()
                                .padding(.vertical, 8)
                            
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
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Daily journal section
                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Daily Activities")
                                .font(.headline)
                            
                            Text("What did you accomplish today? What didn't you get done?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $dailyJournal)
                                .frame(minHeight: 150)
                                .padding(4)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Emotional state section
                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Emotional State")
                                .font(.headline)
                            
                            Text("Describe your emotions and feelings today")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $emotionalState)
                                .frame(minHeight: 150)
                                .padding(4)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                }
            }
        }
    }
    
    private func saveEntry() {
        let updatedEntry = WellbeingEntry(
            id: entry.id,
            date: date,
            mood: mood,
            energy: energy,
            steps: entry.steps,
            screenTimeMinutes: entry.screenTimeMinutes,
            sleepHours: entry.sleepHours,
            heartRate: entry.heartRate,
            caloriesBurned: entry.caloriesBurned,
            waterIntake: entry.waterIntake,
            dailyJournal: dailyJournal,
            emotionalState: emotionalState
        )
        store.updateEntry(updatedEntry)
        presentationMode.wrappedValue.dismiss()
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

