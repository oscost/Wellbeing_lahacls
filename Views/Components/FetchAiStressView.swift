/*
import SwiftUI

class StressorStore: ObservableObject {
    @Published var stressors: [Stressor] = Stressor.mockData()
}

struct StressorsView: View {
    @StateObject private var stressorStore = StressorStore()
    @State private var selectedStressor: Stressor? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                // Current stressors section
                List {
                    Section(header: Text("Current Stressors")) {
                        ForEach(stressorStore.stressors) { stressor in
                            StressorRowView(stressor: stressor)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedStressor = stressor
                                }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Wellbeing Dashboard")
            .sheet(item: $selectedStressor) { stressor in
                StressorDetailView(stressor: stressor)
            }
        }
    }
}

struct StressorRowView: View {
    let stressor: Stressor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(stressor.name)
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(stressorColor)
                    
                    Text("Level \(stressor.level)")
                        .font(.subheadline)
                        .foregroundColor(stressorColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(stressorColor.opacity(0.2))
                .cornerRadius(8)
            }
            
            Text(stressor.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text("Tap for recommendations")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 5)
    }
    
    var stressorColor: Color {
        switch stressor.level {
        case 1...3:
            return .green
        case 4...6:
            return .orange
        case 7...10:
            return .red
        default:
            return .gray
        }
    }
}

struct StressorDetailView: View {
    let stressor: Stressor
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Stressor info
                    VStack(alignment: .leading, spacing: 10) {
                        Text(stressor.name)
                            .font(.largeTitle)
                            .bold()
                        
                        HStack {
                            Text("Stress Level: \(stressor.level)/10")
                                .font(.headline)
                                .foregroundColor(stressorColor)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(stressorColor.opacity(0.2))
                                .cornerRadius(20)
                            
                            Spacer()
                        }
                        
                        Text(stressor.description)
                            .font(.body)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Recommendations
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recommended Actions")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 5)
                        
                        ForEach(stressor.recommendations, id: \.self) { recommendation in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .padding(.top, 3)
                                
                                Text(recommendation)
                                    .font(.body)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Manage Your Stress", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    var stressorColor: Color {
        switch stressor.level {
        case 1...3:
            return .green
        case 4...6:
            return .orange
        case 7...10:
            return .red
        default:
            return .gray
        }
    }
}
/*