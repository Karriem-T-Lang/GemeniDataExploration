import Foundation

// MARK: - Mock Game Model
struct MockGame {
    let team1: String
    let team2: String
    let ats1: Double        // Team 1 spread vs Team 2
    let overUnder: Double   // Total points line
    let pts1: Int           // Team 1 score
    let pts2: Int           // Team 2 score
    let wl1: Int            // 1 if Team 1 won, 0 if lost
    let wl2: Int            // 1 if Team 2 won, 0 if lost
    
    var totalPoints: Int { pts1 + pts2 }
}

// MARK: - Grading Engine Logic
enum BetOutcome: CustomStringConvertible {
    case win
    case loss
    case push
    
    var description: String {
        switch self {
        case .win: return "✅ WIN"
        case .loss: return "❌ LOSS"
        case .push: return "🤝 PUSH"
        }
    }
}

func evaluateWager(betType: String, selection: String, game: MockGame) -> BetOutcome {
    switch betType {
    case "Moneyline":
        if selection.contains(game.team1) {
            return game.wl1 == 1 ? .win : .loss
        } else if selection.contains(game.team2) {
            return game.wl2 == 1 ? .win : .loss
        }
        
    case "Spread":
        if selection.contains(game.team1) {
            let adjusted = Double(game.pts1) + game.ats1
            if adjusted > Double(game.pts2) { return .win }
            if adjusted < Double(game.pts2) { return .loss }
            return .push
        } else if selection.contains(game.team2) {
            let ats2 = -game.ats1
            let adjusted = Double(game.pts2) + ats2
            if adjusted > Double(game.pts1) { return .win }
            if adjusted < Double(game.pts1) { return .loss }
            return .push
        }
        
    case "Total":
        if selection.contains("Over") {
            if Double(game.totalPoints) > game.overUnder { return .win }
            if Double(game.totalPoints) < game.overUnder { return .loss }
            return .push
        } else if selection.contains("Under") {
            if Double(game.totalPoints) < game.overUnder { return .win }
            if Double(game.totalPoints) > game.overUnder { return .loss }
            return .push
        }
        
    default:
        break
    }
    return .loss
}

// MARK: - Test Suite Execution
func runGradingTests() {
    print("==========================================")
    print("      RUNNING BET GRADING UNIT TESTS      ")
    print("==========================================")
    
    // Test Game 1: Celtics vs Knicks (Final Score: Celtics 110, Knicks 100)
    // Line: Celtics -5.5 (ats1 = -5.5), O/U 205.0
    let game1 = MockGame(
        team1: "Celtics",
        team2: "Knicks",
        ats1: -5.5,
        overUnder: 205.0,
        pts1: 110,
        pts2: 100,
        wl1: 1,
        wl2: 0
    )
    
    assertTest(
        name: "Favorite Covers (-5.5 spread)",
        result: evaluateWager(betType: "Spread", selection: "Celtics -5.5", game: game1),
        expected: .win
    )
    
    assertTest(
        name: "Underdog Fails to Cover (+5.5 spread)",
        result: evaluateWager(betType: "Spread", selection: "Knicks +5.5", game: game1),
        expected: .loss
    )
    
    assertTest(
        name: "Over Bet Hits (210 total vs 205.0 line)",
        result: evaluateWager(betType: "Total", selection: "Over 205.0", game: game1),
        expected: .win
    )
    
    // Test Game 2: Push Scenario on Spread (Lakers 105, Warriors 100 | Line: Lakers -5.0)
    let game2 = MockGame(
        team1: "Lakers",
        team2: "Warriors",
        ats1: -5.0,
        overUnder: 205.0,
        pts1: 105,
        pts2: 100,
        wl1: 1,
        wl2: 0
    )
    
    assertTest(
        name: "Spread Push Line Hit Exactly (Lakers -5.0, won by 5)",
        result: evaluateWager(betType: "Spread", selection: "Lakers -5.0", game: game2),
        expected: .push
    )
    
    assertTest(
        name: "Total Push Line Hit Exactly (205 total vs 205.0 O/U)",
        result: evaluateWager(betType: "Total", selection: "Under 205.0", game: game2),
        expected: .push
    )
    
    print("==========================================")
    print("        ALL TESTS EXECUTED CLEANLY        ")
    print("==========================================")
}

func assertTest(name: String, result: BetOutcome, expected: BetOutcome) {
    let status = (result == expected) ? "PASSED" : "FAILED ⚠️"
    print("[\(status)] \(name): Got \(result), Expected \(expected)")
}

// Run the suite
runGradingTests()
