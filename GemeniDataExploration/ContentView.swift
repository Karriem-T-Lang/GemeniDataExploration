//
//  ContentView.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var games: [GameLog]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "basketball.fill")
                    .resizable()
                    .scaledToFit()
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                
                Text("NBA Betting Simulator")
                    .font(.title)
                    .bold()
                
                Text("\(games.count) Games Loaded")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Dashboard")
            .onAppear {
                CSVLoader.seedDatabaseIfNeeded(context: modelContext)
            }
        }
    }
}

// Lightweight Preview using In-Memory Storage
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GameLog.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
