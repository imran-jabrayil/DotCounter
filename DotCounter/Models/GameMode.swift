//
//  GameMode.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import Foundation

/// The team configuration for a game.
///
/// A game is either one player per team (`oneVsOne`) or two players per team
/// (`twoVsTwo`). The raw value is the short label shown in the UI ("1v1"/"2v2")
/// and is also what gets persisted.
enum GameMode: String, Codable {
    /// A single player on each team.
    case oneVsOne = "1v1"
    /// Two players on each team.
    case twoVsTwo = "2v2"
}
