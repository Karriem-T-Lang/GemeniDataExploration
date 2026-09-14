//
//  Untitled.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import SwiftUI
import SwiftData

struct BetHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Bet.date, order: .reverse) private var allBets: [Bet]
    @Query private var userProfiles: [UserProfile]
    
    @State private var showingNukeAlert = false
    @State private var showingNewUserPrompt = false
    @State private var newUsernameInput = ""

    var body: some View {
        NavigationStack {
            List {
                // User Summary Section
                if let profile = userProfiles.first {
                    Section("Active Profile") {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(profile.username)
                                    .font(.headline)
                                Text("Bankroll: $\(profile.bankroll, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                showingNukeAlert = true
                            } label: {
                                Label("Reset All", systemImage: "trash.fill")
                                    .font(.caption)
                                    .bold()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    }
                }
                
                // Bets List Section
                Section("Wager Log (\(allBets.count))") {
                    if allBets.isEmpty {
                        ContentUnavailableView("No Bets Placed", systemImage: "ticket", description: Text("Tap odds on any game to place a wager."))
                    } else {
                        ForEach(allBets) { bet in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(bet.selection)
                                        .font(.headline)
                                    Text("\(bet.betType) • \(bet.odds > 0 ? "+\(bet.odds)" : "\(bet.odds)")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("Date: \(bet.date)")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Wager: $\(bet.wager, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .bold()
                                    Text("To Win: $\(bet.potentialPayout - bet.wager, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Bet History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            // Confirmation alert before nuking data
            .alert("Nuke All Data?", isPresented: $showingNukeAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Nuke Everything", role: .destructive) {
                    nukeAllData()
                }
            } message: {
                Text("This will permanently delete your bankroll history, active profile, and all bet records.")
            }
            // Prompt for new username after nuking
            .alert("Welcome New Player", isPresented: $showingNewUserPrompt) {
                TextField("Enter new username", text: $newUsernameInput)
                Button("Start Fresh") {
                    createNewProfile()
                }
                .disabled(newUsernameInput.trimmingCharacters(in: .whitespaces).isEmpty)
            } message: {
                Text("Enter a unique handle to initialize your new $1,000.00 bankroll.")
            }
        }
    }
    
    private func nukeAllData() {
        // Delete all bets
        for bet in allBets {
            modelContext.delete(bet)
        }
        // Delete all profiles
        for profile in userProfiles {
            modelContext.delete(profile)
        }
        
        try? modelContext.save()
        
        // Present prompt for new username
        newUsernameInput = ""
        showingNewUserPrompt = true
    }
    
    private func createNewProfile() {
        let trimmed = newUsernameInput.trimmingCharacters(in: .whitespaces)
        let handle = trimmed.isEmpty ? "JoeMoneyBagz$" : trimmed
        
        let newProfile = UserProfile(username: handle, startingBankroll: 1000.00)
        modelContext.insert(newProfile)
        try? modelContext.save()
    }
}
