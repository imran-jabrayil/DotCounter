//
//  GameView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var scoreBinding: ScoreBinding
    let team1Name: String
    let team2Name: String

    var body: some View {
        VStack {
            TeamView(team: team1Name, score: $scoreBinding.score1)
            Divider().padding(.vertical)
            TeamView(team: team2Name, score: $scoreBinding.score2)
        }
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let store = GameStore()
    let game = Game(team1: "Team 1", team2: "Team 2", score1: 10, score2: 20)
    store.addGame(game: game)
    let scoreBinding = ScoreBinding(game: game, store: store)
    
    return NavigationStack {
        GameView(scoreBinding: scoreBinding, team1Name: game.team1, team2Name: game.team2)
    }
}
