//
//  Game.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import Foundation

struct Game: Identifiable, Codable {
    let id: UUID
    let team1: String
    let team2: String
    var score1: Int = 0
    var score2: Int = 0
    
    init(id: UUID = UUID(), team1: String, team2: String, score1: Int = 0, score2: Int = 0) {
        self.id = id
        self.team1 = team1
        self.team2 = team2
        self.score1 = score1
        self.score2 = score2
    }
}
