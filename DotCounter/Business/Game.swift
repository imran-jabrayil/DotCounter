//
//  Game.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import SwiftUI

class Game: Identifiable, ObservableObject, Codable {
    let id: UUID
    let createdAt: Date
    
    @Published var team1Name: String
    @Published var team2Name: String
    @Published var team1Score: Int
    @Published var team2Score: Int
    @Published var team1History: [ScoreEntry]
    @Published var team2History: [ScoreEntry]

    enum CodingKeys: String, CodingKey {
        case id, createdAt, team1Name, team2Name, team1Score, team2Score, team1History, team2History
    }

    init(team1Name: String, team2Name: String) {
        self.id = UUID()
        self.createdAt = Date()
        self.team1Name = team1Name
        self.team2Name = team2Name
        self.team1Score = 0
        self.team2Score = 0
        self.team1History = []
        self.team2History = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        team1Name = try container.decodeIfPresent(String.self, forKey: .team1Name) ?? "Team 1"
        team2Name = try container.decodeIfPresent(String.self, forKey: .team2Name) ?? "Team 2"
        team1Score = try container.decode(Int.self, forKey: .team1Score)
        team2Score = try container.decode(Int.self, forKey: .team2Score)
        team1History = try container.decode([ScoreEntry].self, forKey: .team1History)
        team2History = try container.decode([ScoreEntry].self, forKey: .team2History)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(team1Name, forKey: .team1Name)
        try container.encode(team2Name, forKey: .team2Name)
        try container.encode(team1Score, forKey: .team1Score)
        try container.encode(team2Score, forKey: .team2Score)
        try container.encode(team1History, forKey: .team1History)
        try container.encode(team2History, forKey: .team2History)
    }

    func addScore(for team: Int, points: Int) {
        if team == 1 {
            team1Score += points
            team1History.append(ScoreEntry(points: points))
        } else {
            team2Score += points
            team2History.append(ScoreEntry(points: points))
        }
    }

    func undoLastScore(for team: Int) {
        if team == 1 {
            guard let lastEntry = team1History.popLast() else { return }
            team1Score -= lastEntry.points
        } else {
            guard let lastEntry = team2History.popLast() else { return }
            team2Score -= lastEntry.points
        }
    }
}
