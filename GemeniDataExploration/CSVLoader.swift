//
//  CSVLoader.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import Foundation
import SwiftData

struct CSVLoader {
    @MainActor
    static func seedDatabaseIfNeeded(context: ModelContext) {
        // 1. Check if database already has data
        let descriptor = FetchDescriptor<GameLog>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        guard existingCount == 0 else {
            print("Database already seeded with \(existingCount) games.")
            return
        }
        
        // 2. Locate nba.csv in app bundle
        guard let path = Bundle.main.path(forResource: "nba", ofType: "csv"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("Error: Could not locate or read nba.csv in app bundle.")
            return
        }
        
        // 3. Parse rows
        let rows = content.components(separatedBy: .newlines)
        var count = 0
        
        for row in rows.dropFirst() { // Skip header row
            let cols = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            // Expecting 12 columns: date, tm1, ats1, tm2, ou, ml1, ml2, pts1, pts2, tpts, wl1, wl2
            guard cols.count >= 12 else { continue }
            
            let game = GameLog(
                date: cols[0],
                team1: cols[1],
                ats1: Double(cols[2]) ?? 0.0,
                team2: cols[3],
                overUnder: Double(cols[4]) ?? 0.0,
                ml1: Int(cols[5]) ?? 0,
                ml2: Int(cols[6]) ?? 0,
                pts1: Int(cols[7]) ?? 0,
                pts2: Int(cols[8]) ?? 0,
                totalPoints: Int(cols[9]) ?? 0,
                wl1: Int(cols[10]) ?? 0,
                wl2: Int(cols[11]) ?? 0,
                isSimulated: false
            )
            
            context.insert(game)
            count += 1
        }
        
        // 4. Save to SwiftData persistent store
        try? context.save()
        print("Successfully loaded \(count) games into SwiftData!")
    }
}
