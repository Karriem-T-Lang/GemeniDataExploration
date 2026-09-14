//
//  BetSlipView.swift
//  GemeniDataExploration
//
//  Created by Karriem Lang on 9/13/26.
//
import SwiftUI
import SwiftData

struct BetSlipView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let game: GameLog
    let selection: String    // e.g., "Knicks -3.5" or "O 221.5"
    let betType: String      // "Spread", "Total", or "Moneyline"
    let odds: Int            // American odds (-110, +150, etc.)
    let currentBankroll: Double
    
    @Query private var userProfiles: [UserProfile]
    
    @State private var wagerText: String = "10"
    
    private var wagerAmount: Double {
        Double(wagerText) ?? 0.0
    }
    
    // Calculate potential profit based on American odds
    private var potentialProfit: Double {
        guard wagerAmount > 0 else { return 0.0 }
        if odds > 0 {
            return wagerAmount * (Double(odds) / 100.0)
        } else {
            return wagerAmount * (100.0 / Double(abs(odds)))
        }
    }
    
    private var totalPayout: Double {
        wagerAmount + potentialProfit
    }
    
    private var isWagerValid: Bool {
        wagerAmount > 0 && wagerAmount <= currentBankroll
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Game & Selection Summary Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(game.team1) @ \(game.team2)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Text(selection)
                            .font(.title3)
                            .bold()
                        Spacer()
                        Text(odds > 0 ? "+\(odds)" : "\(odds)")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.blue)
                    }
                    
                    Text(betType.uppercased())
                        .font(.caption2)
                        .bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .cornerRadius(6)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Wager Input Field
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Wager Amount")
                            .font(.subheadline)
                            .bold()
                        Spacer()
                        Text("Available: $\(currentBankroll, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundStyle(wagerAmount > currentBankroll ? .red : .secondary)
                    }
                    
                    HStack {
                        Text("$")
                            .font(.title2)
                            .bold()
                        TextField("0.00", text: $wagerText)
                            .font(.title2)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(wagerAmount > currentBankroll ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }

                // Return Details
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("To Win")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$\(potentialProfit, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Return")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$\(totalPayout, specifier: "%.2f")")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                Spacer()

                // Submit Button
                Button(action: placeBet) {
                    Text(wagerAmount > currentBankroll ? "Insufficient Funds" : "Place Bet")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isWagerValid ? Color.green : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!isWagerValid)
            }
            .padding()
            .navigationTitle("Place Bet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func placeBet() {
        guard isWagerValid, let profile = userProfiles.first else { return }
        
        // Deduct wager from bankroll
        profile.bankroll -= wagerAmount
        
        // Persist new Bet entry
        let newBet = Bet(
            date: game.date,
            gameIdString: "\(game.team1)_\(game.team2)_\(game.date)",
            selection: selection,
            betType: betType,
            odds: odds,
            wager: wagerAmount,
            potentialPayout: totalPayout
        )
        
        modelContext.insert(newBet)
        dismiss()
    }
}
