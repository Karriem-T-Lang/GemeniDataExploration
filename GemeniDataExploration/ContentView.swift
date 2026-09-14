//
//  ContentView.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import Foundation
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \GameLog.date) private var games: [GameLog]
    @Query private var userProfiles: [UserProfile]
    
    @State private var currentDateIndex: Int = 0
    @State private var uniqueDates: [String] = []
    
    // Fetch active user bankroll or default safely
    private var currentUsername: String {
        userProfiles.first?.username ?? "JoeMoneyBagz$"
    }
    
    private var currentBankroll: Double {
        userProfiles.first?.bankroll ?? 1000.00
    }
    
    var currentDate: String {
        guard !uniqueDates.isEmpty, currentDateIndex < uniqueDates.count else { return "" }
        return uniqueDates[currentDateIndex]
    }
    
    var gamesForCurrentDate: [GameLog] {
        guard !currentDate.isEmpty else { return [] }
        return games.filter { $0.date == currentDate }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Top Header: User Profile & Bankroll
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(currentUsername)
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.primary)
                            
                            Image(systemName: "person.crop.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                        }
                        
                        Text("$\(currentBankroll, specifier: "%.2f")")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Current Date")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(currentDate.isEmpty ? "----" : currentDate)
                            .font(.title3)
                            .bold()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Day Navigation Controls
                HStack {
                    Button(action: { if currentDateIndex > 0 { currentDateIndex -= 1 } }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                    }
                    .disabled(currentDateIndex == 0)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text(uniqueDates.isEmpty ? "Loading..." : "Day \(currentDateIndex + 1) of \(uniqueDates.count)")
                            .font(.subheadline)
                            .bold()
                        Text("\(gamesForCurrentDate.count) Games Today")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { if currentDateIndex < uniqueDates.count - 1 { currentDateIndex += 1 } }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title2)
                    }
                    .disabled(uniqueDates.isEmpty || currentDateIndex >= uniqueDates.count - 1)
                }
                .padding(.horizontal)

                // Vertical ScrollView
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 16) {
                        ForEach(gamesForCurrentDate) { game in
                            GameCardView(game: game)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("NBA Simulator")
            .onAppear {
                CSVLoader.seedDatabaseIfNeeded(context: modelContext)
                UserManager.ensureUserProfileExists(in: modelContext)
                loadDates()
            }
            .onChange(of: games) { _, _ in
                loadDates()
            }
        }
    }
    
    private func loadDates() {
        if uniqueDates.isEmpty && !games.isEmpty {
            uniqueDates = Array(Set(games.map { $0.date })).sorted()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GameLog.self, UserProfile.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
