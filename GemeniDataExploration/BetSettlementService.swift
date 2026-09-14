//
//  Untitled.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import Foundation
import SwiftData

struct BetSettlementService {
    
    /// Grades all unsettled bets for a specific date against actual game results
    static func evaluateBets(for date: String, context: ModelContext) {
        let predicate = #Predicate<Bet> { bet in
            bet.date == date
        }
        
        let betFetch = FetchDescriptor<Bet>(predicate: predicate)
        let gameFetch = FetchDescriptor<GameLog>(
            predicate: #Predicate<GameLog> { $0.date == date }
        )
        let profileFetch = FetchDescriptor<UserProfile>()
        
        guard let allBetsForDate = try? context.fetch(betFetch),
              let games = try? context.fetch(gameFetch),
              let profile = (try? context.fetch(profileFetch))?.first else {
            return
        }
        
        // Filter for open/unsettled bets
        let pendingBets = allBetsForDate.filter { !$0.isSettled }
        guard !pendingBets.isEmpty else { return }
        
        for bet in pendingBets {
            // Locate corresponding game
            guard let game = games.first(where: { bet.selection.contains($0.team1) || bet.selection.contains($0.team2) }) else {
                continue
            }
            
            var betWon: Bool? = nil
            
            switch bet.betType {
            case "Moneyline":
                if bet.selection.contains(game.team1) {
                    betWon = game.wl1 == 1
                } else if bet.selection.contains(game.team2) {
                    betWon = game.wl2 == 1
                }
                
            case "Spread":
                if bet.selection.contains(game.team1) {
                    let adjustedScore = Double(game.pts1) + game.ats1
                    if adjustedScore > Double(game.pts2) { betWon = true }
                    else if adjustedScore < Double(game.pts2) { betWon = false }
                } else if bet.selection.contains(game.team2) {
                    let adjustedScore = Double(game.pts2) + (-game.ats1)
                    if adjustedScore > Double(game.pts2) { betWon = true }
                    else if adjustedScore < Double(game.pts1) { betWon = false }
                }
                
            case "Total":
                if bet.selection.contains("Over") {
                    if Double(game.totalPoints) > game.overUnder { betWon = true }
                    else if Double(game.totalPoints) < game.overUnder { betWon = false }
                } else if bet.selection.contains("Under") {
                    if Double(game.totalPoints) < game.overUnder { betWon = true }
                    else if Double(game.totalPoints) > game.overUnder { betWon = false }
                }
                
            default:
                break
            }
            
            // Mark bet settled and update bankroll
            bet.isSettled = true
            
            if let won = betWon {
                if won {
                    bet.isWin = true
                    profile.bankroll += bet.potentialPayout
                } else {
                    bet.isWin = false
                }
            } else {
                // Push (Tie) - Return original wager, treat as non-loss push
                bet.isWin = false
                profile.bankroll += bet.wager
            }
        }
        
        try? context.save()
    }
}
