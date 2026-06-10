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
/// tracks the game's mode, status, winner, and the rules in force for this game.
/// All win/end-game logic lives here — not in the views — so the rules stay
/// consistent and unit-testable.
///
/// ## Winning
/// There are two independent ways to win:
/// - **Target win:** a team's cumulative total reaches ``targetScore`` (365 by
///   default). Whether this ends the game automatically is governed by
///   ``autoEndAtTarget``.
/// - **Capot win:** a single +35 (``capotValue``) move wins outright, when
///   ``capotInstantWin`` is enabled.
///
/// ## Per-game rule snapshot
/// ``capotInstantWin``, ``autoEndAtTarget`` and ``targetScore`` are *snapshotted*
/// at creation from the user's global defaults, so changing the app settings
/// later never alters a game that is already in progress.
///
/// The model is CloudKit-compatible: every stored property has a default value
/// and the team relationships are optional, as required by SwiftData's CloudKit
/// integration.
@Model
final class GameSession {
    /// The value of the +35 "capot" move (and button). A single move of this
    /// size wins outright when ``capotInstantWin`` is enabled.
    static let capotValue = 35

    /// The default cumulative score that wins a game.
    static let defaultTargetScore = 365

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

    /// Whether the game was completed by an instant ("capot") +35 win.
    ///
    /// Used to decide whether a completed game can be reopened to undo an
    /// accidental instant win. Defaults to `false` for CloudKit compatibility.
    var wonByInstantWin: Bool = false

    // MARK: Rule snapshot (set at creation from global defaults)

    /// The cumulative score that wins this game. Snapshotted at creation.
    var targetScore: Int = GameSession.defaultTargetScore

    /// When `true`, a single +35 (``capotValue``) move wins instantly.
    var capotInstantWin: Bool = true

    /// When `true`, the game ends automatically the moment a team reaches
    /// ``targetScore``. When `false`, play continues until the game is ended
    /// manually (see ``endGame()``), which then declares whoever reached it.
    var autoEndAtTarget: Bool = true

    /// Creates a new active game between two teams.
    /// - Parameters:
    ///   - gameMode: Whether the game is 1v1 or 2v2.
    ///   - team1: The first team.
    ///   - team2: The second team.
    ///   - capotInstantWin: Whether a single +35 move wins instantly.
    ///   - autoEndAtTarget: Whether reaching ``targetScore`` ends the game automatically.
    ///   - targetScore: The cumulative score that wins the game.
    init(
        gameMode: GameMode,
        team1: Team,
        team2: Team,
        capotInstantWin: Bool = true,
        autoEndAtTarget: Bool = true,
        targetScore: Int = GameSession.defaultTargetScore
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.gameMode = gameMode
        self.team1 = team1
        self.team2 = team2
        self.status = GameStatus.active
        self.winningTeam = nil
        self.wonByInstantWin = false
        self.capotInstantWin = capotInstantWin
        self.autoEndAtTarget = autoEndAtTarget
        self.targetScore = targetScore
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

    /// The outcome of applying a score, so the view can react (e.g. show the
    /// winner alert and a celebration) without re-implementing the rules.
    enum ScoreOutcome {
        /// Points were added; the game continues.
        case scored
        /// A +35 capot move ended the game.
        case capotWin
        /// Reaching ``targetScore`` ended the game.
        case targetWin
    }

    /// Adds `points` to the given side and applies the configured win rules.
    ///
    /// Rule order:
    /// 1. If the move is a +35 capot and ``capotInstantWin`` is enabled, the
    ///    moving team wins instantly (a ``ScoreOutcome/capotWin``).
    /// 2. Otherwise, if ``autoEndAtTarget`` is enabled and the new total reaches
    ///    ``targetScore``, the moving team wins (a ``ScoreOutcome/targetWin``).
    ///    A +35 with capot *disabled* falls through here, so it still counts
    ///    toward the target.
    /// 3. Otherwise the points are simply recorded.
    ///
    /// - Parameters:
    ///   - points: The points to add (always positive in practice).
    ///   - teamNumber: The side receiving the points, `1` or `2`.
    /// - Returns: What happened, so the caller can present a winner UI.
    /// - Important: A no-op returning ``ScoreOutcome/scored`` if the game is not
    ///   active or the team is missing.
    @discardableResult
    func applyScore(points: Int, toTeam teamNumber: Int) -> ScoreOutcome {
        guard status == .active, let team = (teamNumber == 1 ? team1 : team2) else {
            return .scored
        }

        team.addScore(points)

        // 1. Capot single-move win (only when enabled).
        if points == Self.capotValue && capotInstantWin {
            recordInstantWin(for: teamNumber)
            return .capotWin
        }

        // 2. Target reached (only auto-ends when enabled). `>=` handles overshoot.
        if autoEndAtTarget && team.currentScore >= targetScore {
            recordTargetWin(for: teamNumber)
            return .targetWin
        }

        return .scored
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

    /// Records a win earned by reaching ``targetScore`` and completes the game.
    ///
    /// Unlike a capot win, a target win is *not* marked reopenable: it is the
    /// legitimate end of accumulated play, so ``canReopen`` stays `false`.
    ///
    /// - Parameter teamNumber: The winning side, `1` or `2`.
    /// - Important: Mutates ``status``, ``winningTeam`` and ``wonByInstantWin``.
    func recordTargetWin(for teamNumber: Int) {
        winningTeam = teamNumber
        wonByInstantWin = false
        status = .completed
    }

    /// Ends the game manually.
    ///
    /// A winner is declared only if a team has already reached ``targetScore``;
    /// otherwise the game ends without a winner (an abandoned match). team1 is
    /// checked first when both qualify. This is the path used to "finish the
    /// round" when ``autoEndAtTarget`` is disabled.
    ///
    /// - Important: Mutates ``status``, ``winningTeam`` and ``wonByInstantWin``.
    func endGame() {
        status = .completed
        wonByInstantWin = false
        if let team1, team1.currentScore >= targetScore {
            winningTeam = 1
        } else if let team2, team2.currentScore >= targetScore {
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
    /// `true` (target wins and manually ended games are not affected).
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
