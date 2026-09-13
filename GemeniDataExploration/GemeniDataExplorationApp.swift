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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: GameLog.self)
    }
}
