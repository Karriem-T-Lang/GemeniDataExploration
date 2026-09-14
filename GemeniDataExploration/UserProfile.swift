//
//  UserProfile.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var username: String
    var bankroll: Double
    
    init(username: String = "JoeMoneyBagz$", startingBankroll: Double = 1000.00) {
        self.id = UUID()
        self.username = username
        self.bankroll = startingBankroll
    }
}
