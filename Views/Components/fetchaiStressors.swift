// FetchAiStressorsView.swift
import SwiftUI

struct FetchAiStressorsView: View {
    @EnvironmentObject var wellbeingStore: WellbeingStore
    @StateObject private var fetchService = FetchAiService.shared
    @State private var selectedStressor: Stressor? = nil
    @State private var showingErrorAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header section
                VStack(alignment: .leading, spacing: 10) {
                    Text("AI-Powered Insights")
                        .font(.headline)
                    
                    if let lastAnalysis = fetchService.lastAnalysisDate {
                        Text("Last updated: \(dateFormatter.string(from: lastAnalysis))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        // Use real data from the store
                        if !wellbeingStore.entries.isEmpty {
                            fetchService.analyzeUserData(entries: wellbeingStore.entries)
                        } else {
                            // If no data, use sample data for demo
                            fetchService.fetchSampleAnalysis()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Analyze with Fetch.ai")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(fetchService.isAnalyzing)
                    .overlay(
                        Group {
                            if fetchService.isAnalyzing {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Analyzing data...")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Stressors list
                if fetchService.analyzedStressors.isEmpty && !fetchService.isAnalyzing {
                    VStack(spacing: 15) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No insights available yet")
                            .font(.headline)
                        
                        Text("Tap 'Analyze with Fetch.ai' to analyze your journal entries and health data")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        Section(header: Text("AI-Detected Stressors")) {
                            ForEach(fetchService.analyzedStressors) { stressor in
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
            }
            .navigationTitle("Wellbeing Insights")
            .sheet(item: $selectedStressor) { stressor in
                StressorDetailView(stressor: stressor)
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("Analysis Error"),
                    message: Text(fetchService.error ?? "Unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onChange(of: fetchService.error) { newError in
                showingErrorAlert = newError != nil
            }
        }
        .onAppear {
            // If we have entries but no analysis has been run yet, do it automatically
            if !wellbeingStore.entries.isEmpty && fetchService.analyzedStressors.isEmpty {
                fetchService.analyzeUserData(entries: wellbeingStore.entries)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
