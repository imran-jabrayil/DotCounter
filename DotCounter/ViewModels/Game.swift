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
    
    init(id: UUID = UUID(), team1: String, team2: String) {
        self.id = id
        self.team1 = team1
        self.team2 = team2
    }
}
