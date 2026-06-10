//
//  Team.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import Foundation
import SwiftData

@Model
final class Team {
    var player1Name: String = ""
    var player2Name: String? // nil for 1v1 mode
    
    // Cumulative score after each round, starting at 0. Stored inline — the
    // array is small, so external storage (meant for large blobs) is not used.
    var scoreHistory: [Int] = [0]

    var gameSessionAsTeam1: GameSession?
    var gameSessionAsTeam2: GameSession?

    init(player1Name: String, player2Name: String? = nil) {
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.scoreHistory = [0] // Start with 0
    }

    var currentScore: Int {
        scoreHistory.last ?? 0
    }
    
    var displayName: String {
        if let player2 = player2Name {
            return "\(player1Name) & \(player2)"
        }
        return player1Name
    }
    
    func addScore(_ points: Int) {
        let newScore = currentScore + points
        scoreHistory.append(newScore)
    }
    
    func undoLastScore() {
        guard scoreHistory.count > 1 else { return }
        scoreHistory.removeLast()
    }
    
    func canUndo() -> Bool {
        return scoreHistory.count > 1
    }
}

