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
