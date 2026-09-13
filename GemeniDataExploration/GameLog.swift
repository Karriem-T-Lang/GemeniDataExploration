//
//  GameLog.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import Foundation
import SwiftData

@Model
final class GameLog {
    @Attribute(.unique) var id: UUID
    
    // Visible Pre-Game Data
    var date: String
    var team1: String
    var ats1: Double
    var team2: String
    var overUnder: Double
    var ml1: Int
    var ml2: Int
    
    // Hidden Outcomes
    var pts1: Int
    var pts2: Int
    var totalPoints: Int
    var wl1: Int
    var wl2: Int
    
    // Simulation Flag
    var isSimulated: Bool
    
    init(
        id: UUID = UUID(),
        date: String,
        team1: String,
        ats1: Double,
        team2: String,
        overUnder: Double,
        ml1: Int,
        ml2: Int,
        pts1: Int,
        pts2: Int,
        totalPoints: Int,
        wl1: Int,
        wl2: Int,
        isSimulated: Bool = false
    ) {
        self.id = id
        self.date = date
        self.team1 = team1
        self.ats1 = ats1
        self.team2 = team2
        self.overUnder = overUnder
        self.ml1 = ml1
        self.ml2 = ml2
        self.pts1 = pts1
        self.pts2 = pts2
        self.totalPoints = totalPoints
        self.wl1 = wl1
        self.wl2 = wl2
        self.isSimulated = isSimulated
    }
}
