// EntryDetailView.swift
import SwiftUI

struct EntryDetailView: View {
    @EnvironmentObject var store: WellbeingStore
    @State private var showingEditView = false
    let entry: WellbeingEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
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
                
                VStack(alignment: .leading, spacing: 20) {
                    // Mood section
                    HStack {
                        Label("Mood", systemImage: "face.smiling")
                            .font(.headline)
                        Spacer()
                        
                        Text("\(entry.mood)/10")
                            .font(.title3)
                            .bold()
                            .foregroundColor(moodColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(moodColor.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    // Health metrics section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Health Data")
                            .font(.headline)
                        
                        Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 15) {
                            GridRow {
                                Label("\(entry.steps) steps", systemImage: "figure.walk")
                                Label("\(entry.heartRate) bpm", systemImage: "heart")
                            }
                            
                            GridRow {
                                Label("\(entry.screenTimeMinutes) min screen", systemImage: "iphone")
                                Label("\(entry.caloriesBurned) kcal", systemImage: "flame")
                            }
                            
                            GridRow {
                                Label("\(entry.sleepHours, specifier: "%.1f") hrs sleep", systemImage: "bed.double")
                                Label("\(entry.waterIntake) ml water", systemImage: "drop")
                            }
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }
                    
                    // Journal section
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Journal Entry", systemImage: "book")
                            .font(.headline)
                        Text(entry.dailyJournal)
                            .padding(.leading)
                    }
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
}

struct Grid<Content: View>: View {
    let alignment: HorizontalAlignment
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let content: Content
    
    init(alignment: HorizontalAlignment = .center, horizontalSpacing: CGFloat = 8, verticalSpacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: verticalSpacing) {
            content
        }
    }
}

struct GridRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 8) {
            content
        }
    }
}
