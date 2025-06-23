//
//  GameRowView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import SwiftUI

struct GameRowView: View {
    @ObservedObject var game: Game

    var body: some View {
        HStack {
            Text("\(game.team1Name) vs \(game.team2Name)")
                .font(.headline)
            Spacer()
            // The score is no longer displayed here as per the new design
        }
        .padding(.vertical, 8)
    }
}

#Preview("Game Row") {
    let game = Game(team1Name: "Champions", team2Name: "Challengers")
    return GameRowView(game: game)
        .preferredColorScheme(.dark)
        .padding()
}
