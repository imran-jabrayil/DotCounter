//
//  GameSession.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import Foundation
import SwiftData

/// A single domino match between two teams.
///
/// `GameSession` owns the two competing teams (via cascading relationships) and
/// tracks the game's mode, status, and winner. All win/end-game logic lives here
/// — not in the views — so the rules stay consistent and unit-testable.
///
/// The model is CloudKit-compatible: every stored property has a default value
/// and the team relationships are optional, as required by SwiftData's CloudKit
/// integration.
@Model
final class GameSession {
    /// Score that wins a game outright via the "capot" (+35) instant-win button.
    static let winningScore = 35

    /// Stable identifier for the game.
    var id: UUID = UUID()
    /// When the game was created. Used to sort the game list (newest first).
    var createdAt: Date = Date()
    /// Whether this is a 1v1 or 2v2 game.
    var gameMode: GameMode = GameMode.oneVsOne

    /// The first team. Optional and cascade-deleted, as required for CloudKit.
    @Relationship(deleteRule: .cascade, inverse: \Team.gameSessionAsTeam1)
    var team1: Team?

    /// The second team. Optional and cascade-deleted, as required for CloudKit.
    @Relationship(deleteRule: .cascade, inverse: \Team.gameSessionAsTeam2)
    var team2: Team?

    /// The current lifecycle status of the game.
    var status: GameStatus = GameStatus.active

    /// The winning side, `1` or `2`, or `nil` if the game has no winner.
    var winningTeam: Int?

    /// Whether the game was completed by pressing the +35 instant-win button.
    ///
    /// Used to decide whether a completed game can be reopened to undo an
    /// accidental instant win. Defaults to `false` for CloudKit compatibility.
    var wonByInstantWin: Bool = false

    /// Creates a new active game between two teams.
    /// - Parameters:
    ///   - gameMode: Whether the game is 1v1 or 2v2.
    ///   - team1: The first team.
    ///   - team2: The second team.
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

    /// `true` when the game has finished.
    var isCompleted: Bool {
        status == .completed
    }

    /// The team that won, resolved from ``winningTeam``, or `nil` if there is none.
    var winner: Team? {
        switch winningTeam {
        case 1: return team1
        case 2: return team2
        default: return nil
        }
    }

    /// Records an instant ("capot") win for the given team and completes the game.
    ///
    /// The winner is the team that triggered the win — it is deliberately *not*
    /// re-derived from the scores, so a team that happens to already be at the
    /// winning score does not steal the win.
    ///
    /// - Parameter teamNumber: The triggering side, `1` or `2`.
    /// - Important: Mutates ``status``, ``winningTeam`` and ``wonByInstantWin``.
    func recordInstantWin(for teamNumber: Int) {
        winningTeam = teamNumber
        wonByInstantWin = true
        status = .completed
    }

    /// Ends the game manually.
    ///
    /// A winner is declared only if a team has already reached ``winningScore``;
    /// otherwise the game ends without a winner (an abandoned match). team1 is
    /// checked first when both qualify.
    ///
    /// - Important: Mutates ``status``, ``winningTeam`` and ``wonByInstantWin``.
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

    /// Reopens a game that was completed via an instant win.
    ///
    /// Removes the +35 score that ended the game so play can resume from the
    /// prior state, then reactivates the game. No-op unless ``canReopen`` is
    /// `true` (manually ended games are not affected).
    ///
    /// - Important: Mutates the winning team's score history as well as the
    ///   game's ``status``, ``winningTeam`` and ``wonByInstantWin``.
    func reopen() {
        guard canReopen else { return }
        winner?.undoLastScore()
        status = .active
        winningTeam = nil
        wonByInstantWin = false
    }
}
