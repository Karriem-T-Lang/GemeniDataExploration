//
//  GemeniDataExplorationApp.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import SwiftUI
import SwiftData

@main
struct GemeniDataExplorationApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: GameLog.self, Bet.self, UserProfile.self)
            
            // Seed CSV games strictly ONCE on app startup
            let context = ModelContext(container)
            CSVLoader.seedDatabaseIfNeeded(context: context)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
