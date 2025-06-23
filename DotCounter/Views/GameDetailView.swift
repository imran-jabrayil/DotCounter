//
//  GameDetailView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import SwiftUI

struct GameDetailView: View {
    @ObservedObject var game: Game
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TeamControlView(
                    teamName: game.team1Name,
                    score: game.team1Score,
                    lastOperation: game.team1History.last,
                    onAddScore: { points in game.addScore(for: 1, points: points) },
                    onUndo: { game.undoLastScore(for: 1) },
                    canUndo: !game.team1History.isEmpty
                )
                
                TeamControlView(
                    teamName: game.team2Name,
                    score: game.team2Score,
                    lastOperation: game.team2History.last,
                    onAddScore: { points in game.addScore(for: 2, points: points) },
                    onUndo: { game.undoLastScore(for: 2) },
                    canUndo: !game.team2History.isEmpty
                )
            }
            .padding()
        }
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.ignoresSafeArea()) // Set background to black
    }
}


#Preview("Game Detail") {
    let game = Game(team1Name: "Team Alpha", team2Name: "Team Bravo")
    game.team1Score = 25
    game.team2Score = 40
    game.team1History.append(ScoreEntry(points: 25))
    
    return GameDetailView(game: game)
        .preferredColorScheme(.dark)
}
