//
//  Team.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import Foundation
import SwiftData

/// One side of a ``GameSession``: one or two players and their score history.
///
/// Scores are stored as a running, cumulative history (each entry is the total
/// after a round, starting at `0`) so that undo is a simple `removeLast`. The
/// model is CloudKit-compatible: every stored property has a default value.
@Model
final class Team {
    /// Name of the first (always present) player.
    var player1Name: String = ""
    /// Name of the second player, or `nil` in a 1v1 game.
    var player2Name: String?

    // Cumulative score after each round, starting at 0. Stored inline — the
    // array is small, so external storage (meant for large blobs) is not used.
    /// Cumulative score after each round; always begins with `0`.
    var scoreHistory: [Int] = [0]

    /// Back-reference set when this team is ``GameSession/team1``.
    var gameSessionAsTeam1: GameSession?
    /// Back-reference set when this team is ``GameSession/team2``.
    var gameSessionAsTeam2: GameSession?

    /// Creates a team with one or two players.
    /// - Parameters:
    ///   - player1Name: The first player's name.
    ///   - player2Name: The second player's name, or `nil` for a 1v1 team.
    init(player1Name: String, player2Name: String? = nil) {
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.scoreHistory = [0] // Start with 0
    }

    /// The team's current total — the most recent entry in ``scoreHistory``.
    var currentScore: Int {
        scoreHistory.last ?? 0
    }

    /// A display label combining the player name(s), e.g. "Alice" or "Alice & Bob".
    var displayName: String {
        if let player2 = player2Name {
            return "\(player1Name) & \(player2)"
        }
        return player1Name
    }

    /// Adds `points` to the current total, appending a new history entry.
    /// - Parameter points: The points to add (always positive in practice).
    func addScore(_ points: Int) {
        let newScore = currentScore + points
        scoreHistory.append(newScore)
    }

    /// Removes the most recent score entry, reverting to the prior total.
    ///
    /// No-op when the team is already at its starting `0`, so the history can
    /// never shrink below `[0]`.
    func undoLastScore() {
        guard scoreHistory.count > 1 else { return }
        scoreHistory.removeLast()
    }

    /// Whether there is a score entry that can be undone (i.e. not at the start).
    /// - Returns: `true` if ``undoLastScore()`` would change anything.
    func canUndo() -> Bool {
        return scoreHistory.count > 1
    }
}
