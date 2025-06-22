//
//  GameView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import SwiftUI

struct GameView: View {
    @Binding var game: Game
    
    var body: some View {
        VStack {
            TeamView(team: game.team1)
            Divider().padding(.vertical)
            TeamView(team: game.team2)
        }
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let game = Game(team1: "Team 1", team2: "Team 2")
    GameView(game: game)
}
