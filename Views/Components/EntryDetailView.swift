import SwiftUI

struct EntryDetailView: View {
    @EnvironmentObject var store: WellbeingStore
    @State private var showingEditView = false
    let entry: WellbeingEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with date and edit button
                HStack {
                    Text(dateFormatter.string(from: entry.date))
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        showingEditView = true
                    }) {
                        Text("Edit")
                    }
                }
                
                Divider()
                
                // Mood and Energy section
                HStack(spacing: 20) {
                    // Mood card
                    VStack {
                        Label("Mood", systemImage: "face.smiling")
                            .font(.headline)
                        
                        Text("\(entry.mood)/10")
                            .font(.title)
                            .bold()
                            .foregroundColor(moodColor)
                            .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(moodColor.opacity(0.2))
                    .cornerRadius(10)
                    
                    // Energy card
                    VStack {
                        Label("Energy", systemImage: "bolt.fill")
                            .font(.headline)
                        
                        Text("\(entry.energy)/10")
                            .font(.title)
                            .bold()
                            .foregroundColor(energyColor)
                            .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(energyColor.opacity(0.2))
                    .cornerRadius(10)
                }
                
                // Health data section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Health Data")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        HealthMetricView(icon: "figure.walk", value: "\(entry.steps)", label: "Steps")
                        HealthMetricView(icon: "heart.fill", value: "\(entry.heartRate)", label: "BPM")
                        HealthMetricView(icon: "iphone", value: "\(entry.screenTimeMinutes)", label: "Screen min")
                        HealthMetricView(icon: "flame.fill", value: "\(entry.caloriesBurned)", label: "Calories")
                        HealthMetricView(icon: "bed.double.fill", value: String(format: "%.1f", entry.sleepHours), label: "Sleep hrs")
                        HealthMetricView(icon: "drop.fill", value: "\(entry.waterIntake)", label: "Water ml")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Daily activities section
                VStack(alignment: .leading, spacing: 10) {
                    Label("Daily Activities", systemImage: "list.bullet")
                        .font(.headline)
                    
                    Text(entry.dailyJournal)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Emotional state section
                VStack(alignment: .leading, spacing: 10) {
                    Label("Emotional State", systemImage: "heart.text.square")
                        .font(.headline)
                    
                    Text(entry.emotionalState)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Entry Details")
        .sheet(isPresented: $showingEditView) {
            EditEntryView(entry: entry)
                .environmentObject(store)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    private var moodColor: Color {
        switch entry.mood {
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
    
    private var energyColor: Color {
        switch entry.energy {
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

struct HealthMetricView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}
