import SwiftUI

struct JournalListView: View {
    @EnvironmentObject var store: WellbeingStore
    @State private var showingAddEntryView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.entries.sorted(by: { $0.date > $1.date })) { entry in
                    NavigationLink(destination: EntryDetailView(entry: entry)) {
                        EntryRowView(entry: entry)
                    }
                }
                .onDelete(perform: store.deleteEntry)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Daily Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddEntryView = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntryView) {
                AddEntryView()
                    .environmentObject(store)
            }
        }
    }
}
