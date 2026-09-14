//
//  GameCardView.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import SwiftUI
import SwiftData

// Data wrapper for selected wager state
struct BetSelection: Identifiable {
    let id = UUID()
    let selection: String
    let betType: String
    let odds: Int
}

struct GameCardView: View {
    let game: GameLog
    
    @Query private var userProfiles: [UserProfile]
    @State private var activeBetSelection: BetSelection?
    
    private var currentBankroll: Double {
        userProfiles.first?.bankroll ?? 1000.00
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Teams & Date
            HStack {
                Text("\(game.team1) vs \(game.team2)")
                    .font(.headline)
                    .bold()
                Spacer()
                Text(game.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Odds Grid Header
            HStack {
                Text("TEAMS")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("SPREAD")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(width: 70)
                
                Text("TOTAL")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(width: 70)
                
                Text("MONEY")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(width: 70)
            }
            
            // Team 1 Row
            HStack {
                Text(game.team1)
                    .font(.subheadline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Spread 1 (ats1)
                OddsBox(title: String(format: "%+.1f", game.ats1), odds: -110)
                    .onTapGesture {
                        activeBetSelection = BetSelection(
                            selection: "\(game.team1) \(game.ats1 >= 0 ? "+" : "")\(game.ats1)",
                            betType: "Spread",
                            odds: -110
                        )
                    }
                
                // Over line
                OddsBox(title: "O \(game.overUnder)", odds: -110)
                    .onTapGesture {
                        activeBetSelection = BetSelection(
                            selection: "Over \(game.overUnder)",
                            betType: "Total",
                            odds: -110
                        )
                    }
                
                // Moneyline 1
                OddsBox(title: "ML", odds: game.ml1)
                    .onTapGesture {
                        activeBetSelection = BetSelection(
                            selection: "\(game.team1) ML",
                            betType: "Moneyline",
                            odds: game.ml1
                        )
                    }
            }
            
            // Team 2 Row
            HStack {
                Text(game.team2)
                    .font(.subheadline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Spread 2 (-ats1 inverse)
                OddsBox(title: String(format: "%+.1f", -game.ats1), odds: -110)
                    .onTapGesture {
                        let ats2 = -game.ats1
                        activeBetSelection = BetSelection(
                            selection: "\(game.team2) \(ats2 >= 0 ? "+" : "")\(ats2)",
                            betType: "Spread",
                            odds: -110
                        )
                    }
                
                // Under line
                OddsBox(title: "U \(game.overUnder)", odds: -110)
                    .onTapGesture {
                        activeBetSelection = BetSelection(
                            selection: "Under \(game.overUnder)",
                            betType: "Total",
                            odds: -110
                        )
                    }
                
                // Moneyline 2
                OddsBox(title: "ML", odds: game.ml2)
                    .onTapGesture {
                        activeBetSelection = BetSelection(
                            selection: "\(game.team2) ML",
                            betType: "Moneyline",
                            odds: game.ml2
                        )
                    }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        .sheet(item: $activeBetSelection) { bet in
            BetSlipView(
                game: game,
                selection: bet.selection,
                betType: bet.betType,
                odds: bet.odds,
                currentBankroll: currentBankroll
            )
        }
    }
}

// Reusable subview for individual odds buttons
struct OddsBox: View {
    let title: String
    let odds: Int
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .bold()
            Text(odds > 0 ? "+\(odds)" : "\(odds)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 70, height: 44)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .contentShape(Rectangle())
    }
}
