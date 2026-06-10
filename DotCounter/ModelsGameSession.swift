//
//  GameSession.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//
//  Represents a single domino match between two teams, including its mode,
//  status, and the winning team. Win/end-game logic lives here (not in the
//  views) so it stays consistent and testable.
//

import Foundation
import SwiftData

@Model
final class GameSession {
    /// Score that wins a game outright via the "capot" (+35) instant-win button.
    static let winningScore = 35

    var id: UUID = UUID()
    var createdAt: Date = Date()
    var gameMode: GameMode = GameMode.oneVsOne

    @Relationship(deleteRule: .cascade, inverse: \Team.gameSessionAsTeam1)
    var team1: Team?

    @Relationship(deleteRule: .cascade, inverse: \Team.gameSessionAsTeam2)
    var team2: Team?

    var status: GameStatus = GameStatus.active

    /// The winning side, 1 or 2, or `nil` if the game has no winner.
    var winningTeam: Int?

    /// Whether the game was completed by pressing the +35 instant-win button.
    /// Used to decide whether a completed game can be reopened to undo an
    /// accidental instant win. Defaults to `false` for CloudKit compatibility.
    var wonByInstantWin: Bool = false

    init(gameMode: GameMode, team1: Team, team2: Team) {
        self.id = UUID()
        self.createdAt = Date()
        self.gameMode = gameMode
        self.team1 = team1
        self.team2 = team2
        self.status = GameStatus.active
        self.winningTeam = nil
        self.wonByInstantWin = false
    }

    var isCompleted: Bool {
        status == .completed
    }

    /// The team that won, resolved from `winningTeam`, or `nil` if there is none.
    var winner: Team? {
        switch winningTeam {
        case 1: return team1
        case 2: return team2
        default: return nil
        }
    }

    /// Records an instant ("capot") win for the given team and completes the game.
    /// The winner is the team that triggered the win — it is not re-derived from
    /// the scores, so a team that happens to already be at the winning score does
    /// not steal the win.
    /// - Parameter teamNumber: The triggering side, 1 or 2.
    func recordInstantWin(for teamNumber: Int) {
        winningTeam = teamNumber
        wonByInstantWin = true
        status = .completed
    }

    /// Ends the game manually. A winner is declared only if a team has already
    /// reached `winningScore`; otherwise the game ends without a winner.
    func endGame() {
        status = .completed
        wonByInstantWin = false
        if let team1, team1.currentScore >= Self.winningScore {
            winningTeam = 1
        } else if let team2, team2.currentScore >= Self.winningScore {
            winningTeam = 2
        } else {
            winningTeam = nil
        }
    }

    /// Whether a completed game can be reopened to undo an accidental instant win.
    var canReopen: Bool {
        status == .completed && wonByInstantWin
    }

    /// Reopens a game that was completed via an instant win, removing the +35
    /// score that ended it so play can resume from the prior state.
    func reopen() {
        guard canReopen else { return }
        winner?.undoLastScore()
        status = .active
        winningTeam = nil
        wonByInstantWin = false
    }
}

enum GameMode: String, Codable {
    case oneVsOne = "1v1"
    case twoVsTwo = "2v2"
}

enum GameStatus: String, Codable {
    case active = "Active"
    case completed = "Completed"
}
