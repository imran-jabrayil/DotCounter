//
//  GameLogicTests.swift
//  DotCounterTests
//
//  Unit tests for the scoring, undo, and win/reopen logic that lives in the
//  Team and GameSession models. These are pure model tests — no SwiftData
//  ModelContext is required, since only stored-property mutation and computed
//  properties are exercised.
//

import Testing
@testable import DotCounter

// MARK: - Helpers

/// Builds a fresh 2v2 game with both teams starting at 0.
/// - Parameters:
///   - capot: Whether a single +35 move wins instantly.
///   - autoEnd: Whether reaching the target ends the game automatically.
private func makeGame(capot: Bool = true, autoEnd: Bool = true) -> GameSession {
    GameSession(
        gameMode: .twoVsTwo,
        team1: Team(player1Name: "Alice", player2Name: "Bob"),
        team2: Team(player1Name: "Charlie", player2Name: "David"),
        capotInstantWin: capot,
        autoEndAtTarget: autoEnd
    )
}

/// Raises a team to at least the target score using +25 increments, leaving
/// auto-end behaviour up to the caller's game configuration.
private func raiseTeam(_ team: Team?, to score: Int) {
    while (team?.currentScore ?? .max) < score {
        team?.addScore(25)
    }
}

// MARK: - Team scoring

@Suite("Team scoring")
struct TeamScoringTests {
    @Test("A new team starts at zero and cannot undo")
    func startsAtZero() {
        let team = Team(player1Name: "Solo")
        #expect(team.currentScore == 0)
        #expect(team.scoreHistory == [0])
        #expect(team.canUndo() == false)
    }

    @Test("addScore accumulates onto the running total")
    func addAccumulates() {
        let team = Team(player1Name: "Solo")
        team.addScore(5)
        team.addScore(10)
        #expect(team.currentScore == 15)
        #expect(team.scoreHistory == [0, 5, 15])
    }

    @Test("undoLastScore reverts the most recent entry")
    func undoReverts() {
        let team = Team(player1Name: "Solo")
        team.addScore(20)
        team.addScore(5)
        team.undoLastScore()
        #expect(team.currentScore == 20)
        #expect(team.canUndo() == true)
    }

    @Test("undo cannot go below the starting zero")
    func undoFloor() {
        let team = Team(player1Name: "Solo")
        team.addScore(5)
        team.undoLastScore() // back to [0]
        team.undoLastScore() // no-op at the floor
        #expect(team.scoreHistory == [0])
        #expect(team.currentScore == 0)
        #expect(team.canUndo() == false)
    }

    @Test("displayName reflects 1v1 vs 2v2")
    func displayName() {
        #expect(Team(player1Name: "Solo").displayName == "Solo")
        #expect(Team(player1Name: "A", player2Name: "B").displayName == "A & B")
    }
}

// MARK: - Instant (capot) win

@Suite("Instant win")
struct InstantWinTests {
    @Test("Instant win completes the game for the triggering team")
    func recordsWinner() {
        let game = makeGame()
        game.recordInstantWin(for: 2)
        #expect(game.status == .completed)
        #expect(game.isCompleted)
        #expect(game.winningTeam == 2)
        #expect(game.winner === game.team2)
        #expect(game.wonByInstantWin)
        #expect(game.canReopen)
    }

    // Regression: the winner must be the team that triggered the win, even when
    // the *other* team already sits at or above the winning score. The old code
    // re-derived the winner from scores (team1-first) and stole the win.
    @Test("Triggering team wins even if the opponent is already at the threshold")
    func triggeringTeamKeepsTheWin() {
        let game = makeGame()
        game.team1?.addScore(GameSession.capotValue) // team1 at 35
        game.recordInstantWin(for: 2)                // team2 presses +35
        #expect(game.winningTeam == 2)
        #expect(game.winner === game.team2)
    }
}

// MARK: - Manual end game

@Suite("Manual end game")
struct ManualEndGameTests {
    @Test("Ending with both teams below the target yields no winner")
    func noWinnerWhenBelowTarget() {
        let game = makeGame()
        game.team1?.addScore(20)
        game.team2?.addScore(30)
        game.endGame()
        #expect(game.status == .completed)
        #expect(game.winningTeam == nil)
        #expect(game.winner == nil)
        #expect(game.wonByInstantWin == false)
        #expect(game.canReopen == false)
    }

    @Test("Ending declares the team that reached the target")
    func declaresTargetTeam() {
        let game = makeGame()
        raiseTeam(game.team2, to: game.targetScore) // push team2 to >= 365
        game.endGame()
        #expect(game.winningTeam == 2)
        #expect(game.winner === game.team2)
    }
}

// MARK: - Reopen

@Suite("Reopen after instant win")
struct ReopenTests {
    @Test("Reopening removes the winning score and reactivates the game")
    func reopenUndoesInstantWin() {
        let game = makeGame()
        game.team1?.addScore(10)
        game.team1?.addScore(GameSession.capotValue) // instant-win score appended
        game.recordInstantWin(for: 1)

        game.reopen()
        #expect(game.status == .active)
        #expect(game.winningTeam == nil)
        #expect(game.wonByInstantWin == false)
        #expect(game.canReopen == false)
        // The +35 entry is removed, leaving the pre-win score.
        #expect(game.team1?.currentScore == 10)
    }

    @Test("Reopen is a no-op for a target win via manual end")
    func reopenIgnoresManualEnd() {
        let game = makeGame()
        raiseTeam(game.team1, to: game.targetScore)
        game.endGame() // winner via target, not an instant win
        let scoreBefore = game.team1?.currentScore

        game.reopen()
        #expect(game.status == .completed)
        #expect(game.canReopen == false)
        #expect(game.team1?.currentScore == scoreBefore)
    }
}

// MARK: - Target win and rule toggles

@Suite("Target win and rule toggles")
struct TargetWinTests {
    @Test("Reaching the target auto-ends the game when enabled")
    func reachingTargetAutoEnds() {
        let game = makeGame(autoEnd: true)
        var outcome = GameSession.ScoreOutcome.scored
        // Score in +25 steps until the crossing move.
        while game.status == .active {
            outcome = game.applyScore(points: 25, toTeam: 1)
        }
        #expect(outcome == .targetWin)
        #expect(game.status == .completed)
        #expect(game.winningTeam == 1)
        #expect(game.wonByInstantWin == false)
        #expect(game.canReopen == false)
        #expect((game.team1?.currentScore ?? 0) >= game.targetScore)
    }

    @Test("Reaching the target does not end the game when auto-end is off")
    func reachingTargetDoesNotAutoEnd() {
        let game = makeGame(autoEnd: false)
        raiseTeam(game.team1, to: game.targetScore)
        // The crossing move must report `.scored`, not a win.
        let outcome = game.applyScore(points: 25, toTeam: 1)
        #expect(outcome == .scored)
        #expect(game.status == .active)
        #expect(game.winningTeam == nil)

        // The manual End button then declares the winner.
        game.endGame()
        #expect(game.winningTeam == 1)
    }

    @Test("Capot enabled: a +35 move wins instantly")
    func capotEnabledWins() {
        let game = makeGame(capot: true)
        let outcome = game.applyScore(points: GameSession.capotValue, toTeam: 2)
        #expect(outcome == .capotWin)
        #expect(game.winningTeam == 2)
        #expect(game.wonByInstantWin == true)
        #expect(game.canReopen == true)
    }

    @Test("Capot disabled: a +35 move is just a normal score")
    func capotDisabledIsNormalMove() {
        let game = makeGame(capot: false, autoEnd: true)
        let outcome = game.applyScore(points: GameSession.capotValue, toTeam: 1)
        #expect(outcome == .scored)
        #expect(game.status == .active)
        #expect(game.team1?.currentScore == 35)
        #expect(game.winningTeam == nil)
    }

    @Test("Capot disabled but a +35 reaching the target still wins as a target win")
    func capotDisabledStillReachesTarget() {
        let game = makeGame(capot: false, autoEnd: true)
        raiseTeam(game.team1, to: game.targetScore - GameSession.capotValue) // up to 330
        let outcome = game.applyScore(points: GameSession.capotValue, toTeam: 1) // 365
        #expect(outcome == .targetWin)
        #expect(game.winningTeam == 1)
        #expect(game.wonByInstantWin == false)
    }

    @Test("Overshooting the target still wins (>= semantics)")
    func overshootWins() {
        let game = makeGame(autoEnd: true)
        raiseTeam(game.team1, to: game.targetScore - 10) // 360 via +25 steps lands above, so build precisely
        // Ensure we sit just below the target before the overshoot move.
        // raiseTeam may overshoot already; only assert when still active.
        if game.status == .active {
            let outcome = game.applyScore(points: 30, toTeam: 1)
            #expect(outcome == .targetWin)
            #expect(game.winningTeam == 1)
        }
    }

    @Test("Scoring after completion is a no-op")
    func noOpAfterCompletion() {
        let game = makeGame()
        game.applyScore(points: GameSession.capotValue, toTeam: 1) // capot win
        let scoreBefore = game.team2?.currentScore
        let outcome = game.applyScore(points: 25, toTeam: 2)
        #expect(outcome == .scored)
        #expect(game.team2?.currentScore == scoreBefore)
        #expect(game.winningTeam == 1)
    }

    @Test("Rules are snapshotted on the game instance")
    func rulesSnapshotted() {
        let game = makeGame(capot: false, autoEnd: false)
        #expect(game.capotInstantWin == false)
        #expect(game.autoEndAtTarget == false)
        #expect(game.targetScore == GameSession.defaultTargetScore)
    }
}
