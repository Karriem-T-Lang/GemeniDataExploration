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
                // Top Header: Bankroll & Date
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bankroll")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
                ensureUserProfileExists()
                
                if uniqueDates.isEmpty {
                    uniqueDates = Array(Set(games.map { $0.date })).sorted()
                }
            }
            .onChange(of: games.count) { _, _ in
                uniqueDates = Array(Set(games.map { $0.date })).sorted()
            }
        }
    }
    
    // Seed initial user profile ($1,000.00) if none exists
    private func ensureUserProfileExists() {
        if userProfiles.isEmpty {
            let initialProfile = UserProfile(startingBankroll: 1000.00)
            modelContext.insert(initialProfile)
        }
    }
}

// 3-Column Sportsbook Card View
struct GameCardView: View {
    let game: GameLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Matchup Teams + Status Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(game.team1) @")
                        .font(.headline)
                    Text(game.team2)
                        .font(.headline)
                }
                
                Spacer()
                
                Text(game.isSimulated ? "FINAL" : "UPCOMING")
                    .font(.caption2)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(game.isSimulated ? Color.gray.opacity(0.2) : Color.blue.opacity(0.15))
                    .foregroundColor(game.isSimulated ? .secondary : .blue)
                    .cornerRadius(12)
            }
            
            Divider()
            
            // 3-Column Odds Layout
            HStack(alignment: .top, spacing: 8) {
                // Spread Column
                OddsBox(title: "SPREAD") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(shortName(game.team1)) \(game.ats1 > 0 ? "+\(game.ats1)" : "\(game.ats1)")")
                        Text("\(shortName(game.team2)) \(-game.ats1 > 0 ? "+\(-game.ats1)" : "\(-game.ats1)")")
                    }
                }
                
                // Total Column
                OddsBox(title: "TOTAL") {
                    VStack(alignment: .center, spacing: 6) {
                        Text("O \(game.overUnder, specifier: "%.1f")")
                        Text("U \(game.overUnder, specifier: "%.1f")")
                    }
                }
                
                // Moneyline Column
                OddsBox(title: "MONEYLINE") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(shortName(game.team1)) \(game.ml1 > 0 ? "+\(game.ml1)" : "\(game.ml1)")")
                        Text("\(shortName(game.team2)) \(game.ml2 > 0 ? "+\(game.ml2)" : "\(game.ml2)")")
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    private func shortName(_ fullTeam: String) -> String {
        let parts = fullTeam.components(separatedBy: " ")
        return parts.last ?? fullTeam
    }
}

// Container for 3-Column Odds Box
struct OddsBox<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption2)
                .bold()
                .foregroundStyle(.secondary)
            
            content
                .font(.caption)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GameLog.self, UserProfile.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
