//
//  GameCardView.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import SwiftUI

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
                OddsBox(title: "SPREAD") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(shortName(game.team1)) \(game.ats1 > 0 ? "+\(game.ats1)" : "\(game.ats1)")")
                        Text("\(shortName(game.team2)) \(-game.ats1 > 0 ? "+\(-game.ats1)" : "\(-game.ats1)")")
                    }
                }
                
                OddsBox(title: "TOTAL") {
                    VStack(alignment: .center, spacing: 6) {
                        Text("O \(game.overUnder, specifier: "%.1f")")
                        Text("U \(game.overUnder, specifier: "%.1f")")
                    }
                }
                
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

// Subview Container for Individual Odds Column
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
