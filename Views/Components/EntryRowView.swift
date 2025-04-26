import SwiftUI

struct EntryRowView: View {
    let entry: WellbeingEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateFormatter.string(from: entry.date))
                .font(.headline)
            
            HStack {
                Label("Mood: \(entry.mood)/10", systemImage: "face.smiling")
                Spacer()
                Text(entry.dailyJournal.prefix(50) + (entry.dailyJournal.count > 50 ? "..." : ""))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 5)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
