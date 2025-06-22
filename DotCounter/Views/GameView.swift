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
            TeamView(team: team1Name, isTeam1: true, scoreBinding: scoreBinding)
            Divider().padding(.vertical)
            TeamView(team: team2Name, isTeam1: false, scoreBinding: scoreBinding)
        }
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let game = Game(team1: "Team 1", team2: "Team 2", score1: 10, score2: 20)
    let store = GameStore()
    let scoreBinding = ScoreBinding(game: game, store: store)

    NavigationStack {
        GameView(scoreBinding: scoreBinding, team1Name: game.team1, team2Name: game.team2)
    }
}
