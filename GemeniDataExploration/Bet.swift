//
//  Bet.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import Foundation
import SwiftData

@Model
final class Bet {
    var id: UUID
    var date: String
    var gameIdString: String // Links bet to a specific GameLog
    var selection: String    // e.g., "Knicks +6.0", "O 221.5", "Celtics -250"
    var betType: String      // "Spread", "Total", "Moneyline"
    var odds: Int            // American odds (-110, +205, etc.)
    var wager: Double
    var potentialPayout: Double
    var isSettled: Bool
    var isWin: Bool
    
    init(date: String, gameIdString: String, selection: String, betType: String, odds: Int, wager: Double, potentialPayout: Double) {
        self.id = UUID()
        self.date = date
        self.gameIdString = gameIdString
        self.selection = selection
        self.betType = betType
        self.odds = odds
        self.wager = wager
        self.potentialPayout = potentialPayout
        self.isSettled = false
        self.isWin = false
    }
}
