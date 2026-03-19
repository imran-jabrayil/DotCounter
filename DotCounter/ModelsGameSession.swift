//
//  GameSession.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import Foundation
import SwiftData

@Model
final class GameSession {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var gameMode: GameMode = GameMode.twoVsTwo
    
    @Relationship(deleteRule: .cascade, inverse: \Team.gameSessionAsTeam1)
    var team1: Team?
    
    @Relationship(deleteRule: .cascade, inverse: \Team.gameSessionAsTeam2)
    var team2: Team?
    
    var status: GameStatus = GameStatus.active
    var winningTeam: Int? // 1 or 2
    
    init(gameMode: GameMode, team1: Team, team2: Team) {
        self.id = UUID()
        self.createdAt = Date()
        self.gameMode = gameMode
        self.team1 = team1
        self.team2 = team2
        self.status = GameStatus.active
        self.winningTeam = nil
    }
    
    var isCompleted: Bool {
        status == .completed
    }
    
    func endGame() {
        status = .completed
        if let team1 = team1, team1.currentScore >= 35 {
            winningTeam = 1
        } else if let team2 = team2, team2.currentScore >= 35 {
            winningTeam = 2
        }
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
