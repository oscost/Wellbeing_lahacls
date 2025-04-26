// EditEntryView.swift
import SwiftUI

struct EditEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: WellbeingStore
    
    let entry: WellbeingEntry
    
    @State private var date: Date
    @State private var mood: Int
    @State private var dailyJournal: String
    
    init(entry: WellbeingEntry) {
        self.entry = entry
        _date = State(initialValue: entry.date)
        _mood = State(initialValue: entry.mood)
        _dailyJournal = State(initialValue: entry.dailyJournal)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date")) {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .labelsHidden()
                }
                
                Section(header: Text("Health Data (Auto-collected)")) {
                    HStack {
                        Label("Steps", systemImage: "figure.walk")
                        Spacer()
                        Text("\(entry.steps)")
                    }
                    
                    HStack {
                        Label("Screen Time", systemImage: "iphone")
                        Spacer()
                        Text("\(entry.screenTimeMinutes) min")
                    }
                    
                    HStack {
                        Label("Sleep", systemImage: "bed.double")
                        Spacer()
                        Text("\(entry.sleepHours, specifier: "%.1f") hrs")
                    }
                    
                    HStack {
                        Label("Heart Rate", systemImage: "heart")
                        Spacer()
                        Text("\(entry.heartRate) bpm")
                    }
                    
                    HStack {
                        Label("Calories", systemImage: "flame")
                        Spacer()
                        Text("\(entry.caloriesBurned) kcal")
                    }
                    
                    HStack {
                        Label("Water", systemImage: "drop")
                        Spacer()
                        Text("\(entry.waterIntake) ml")
                    }
                }
                
                Section(header: Text("How was your day?")) {
                    VStack {
                        Text("Mood: \(mood)/10")
                            .font(.headline)
                        
                        HStack {
                            Text("1")
                                .foregroundColor(.red)
                            
                            Slider(value: Binding(
                                get: { Double(mood) },
                                set: { mood = Int($0) }
                            ), in: 1...10, step: 1)
                            
                            Text("10")
                                .foregroundColor(.green)
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
                        .padding(.top, 5)
                    }
                }
                
                Section(header: Text("Describe your day")) {
                    TextEditor(text: $dailyJournal)
                        .frame(minHeight: 150)
                }
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
                        let updatedEntry = WellbeingEntry(
                            id: entry.id,
                            date: date,
                            mood: mood,
                            steps: entry.steps,
                            screenTimeMinutes: entry.screenTimeMinutes,
                            sleepHours: entry.sleepHours,
                            heartRate: entry.heartRate,
                            caloriesBurned: entry.caloriesBurned,
                            waterIntake: entry.waterIntake,
                            dailyJournal: dailyJournal
                        )
                        store.updateEntry(updatedEntry)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
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
}
