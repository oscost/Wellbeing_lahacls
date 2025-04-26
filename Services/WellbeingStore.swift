import Foundation
import Combine

class WellbeingStore: ObservableObject {
    @Published var entries: [WellbeingEntry] = []
    
    private static func fileURL() -> URL {
        try! FileManager.default.url(for: .documentDirectory,
                                     in: .userDomainMask,
                                     appropriateFor: nil,
                                     create: true)
            .appendingPathComponent("wellbeingData.json")
    }
    
    init() {
        loadData()
        // If no data exists, create mock data
        if entries.isEmpty {
            entries = WellbeingEntry.mockData()
            saveData()
        }
    }
    
    func addEntry(_ entry: WellbeingEntry) {
        entries.append(entry)
        saveData()
    }
    
    func updateEntry(_ entry: WellbeingEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveData()
        }
    }
    
    func deleteEntry(at indexSet: IndexSet) {
        entries.remove(atOffsets: indexSet)
        saveData()
    }
    
    func loadData() {
        let fileURL = Self.fileURL()
        
        if let data = try? Data(contentsOf: fileURL) {
            if let decodedEntries = try? JSONDecoder().decode([WellbeingEntry].self, from: data) {
                entries = decodedEntries
                return
            }
        }
        
        // If loading fails, start with empty array
        entries = []
    }
    
    func saveData() {
        let fileURL = Self.fileURL()
        
        if let encodedData = try? JSONEncoder().encode(entries) {
            try? encodedData.write(to: fileURL)
        }
    }
}
