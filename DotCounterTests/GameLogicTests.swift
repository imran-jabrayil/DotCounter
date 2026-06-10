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
private func makeGame() -> GameSession {
    GameSession(
        gameMode: .twoVsTwo,
        team1: Team(player1Name: "Alice", player2Name: "Bob"),
        team2: Team(player1Name: "Charlie", player2Name: "David")
    )
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

// MARK: - Instant win

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
        game.team1?.addScore(GameSession.winningScore) // team1 at 35
        game.recordInstantWin(for: 2)                  // team2 presses +35
        #expect(game.winningTeam == 2)
        #expect(game.winner === game.team2)
    }
}

// MARK: - Manual end game

@Suite("Manual end game")
struct ManualEndGameTests {
    @Test("Ending with both teams below the threshold yields no winner")
    func noWinnerWhenBelowThreshold() {
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

    @Test("Ending declares the team that reached the threshold")
    func declaresThresholdTeam() {
        let game = makeGame()
        game.team2?.addScore(GameSession.winningScore)
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
        game.team1?.addScore(GameSession.winningScore) // instant-win score appended
        game.recordInstantWin(for: 1)

        game.reopen()
        #expect(game.status == .active)
        #expect(game.winningTeam == nil)
        #expect(game.wonByInstantWin == false)
        #expect(game.canReopen == false)
        // The +35 entry is removed, leaving the pre-win score.
        #expect(game.team1?.currentScore == 10)
    }

    @Test("Reopen is a no-op for a manually ended game")
    func reopenIgnoresManualEnd() {
        let game = makeGame()
        game.team1?.addScore(GameSession.winningScore)
        game.endGame() // winner via threshold, not an instant win
        let scoreBefore = game.team1?.currentScore

        game.reopen()
        #expect(game.status == .completed)
        #expect(game.team1?.currentScore == scoreBefore)
    }
}
