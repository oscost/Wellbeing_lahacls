import SwiftUI

struct AddEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: WellbeingStore
    
    @State private var date = Date()
    @State private var mood = 5
    @State private var dailyJournal = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date")) {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .labelsHidden()
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
                        .overlay(
                            Group {
                                if dailyJournal.isEmpty {
                                    HStack {
                                        Text("Describe what happened today...")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 4)
                                        Spacer()
                                    }
                                }
                            }
                        )
                }
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newEntry = WellbeingEntry(
                            date: date,
                            mood: mood,
                            dailyJournal: dailyJournal
                        )
                        store.addEntry(newEntry)
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
