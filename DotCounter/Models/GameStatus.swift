//
//  GameStatus.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import Foundation

/// Whether a game is still being played or has finished.
///
/// The raw value is the human-readable label shown in the UI (e.g. in
/// ``StatusBadge``) and is also what gets persisted.
enum GameStatus: String, Codable {
    /// The game is in progress and accepting scores.
    case active = "Active"
    /// The game has ended; scoring is disabled.
    case completed = "Completed"
}
