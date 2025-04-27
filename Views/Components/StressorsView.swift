import SwiftUI

struct EntryRowView: View {
    let entry: WellbeingEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date and mood indicator
            HStack {
                Text(dateFormatter.string(from: entry.date))
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 4) {
                    // Mood indicator
                    Image(systemName: "face.smiling")
                        .foregroundColor(moodColor)
                    
                    Text("\(entry.mood)/10")
                        .font(.subheadline)
                        .foregroundColor(moodColor)
                    
                    // Energy indicator
                    Image(systemName: "bolt.fill")
                        .foregroundColor(energyColor)
                        .padding(.leading, 5)
                    
                    Text("\(entry.energy)/10")
                        .font(.subheadline)
                        .foregroundColor(energyColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Journal preview
            Text(entry.dailyJournal.prefix(70) + (entry.dailyJournal.count > 70 ? "..." : ""))
                .foregroundColor(.secondary)
                .font(.subheadline)
                .lineLimit(2)
        }
        .padding(.vertical, 5)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
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
