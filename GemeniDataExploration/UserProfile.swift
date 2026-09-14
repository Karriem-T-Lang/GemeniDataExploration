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
    var bankroll: Double
    
    init(startingBankroll: Double = 1000.00) {
        self.id = UUID()
        self.bankroll = startingBankroll
    }
}
