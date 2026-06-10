//
//  GameInfoCard.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI

/// The large, card-style score summary shown at the top of the iPad layout.
///
/// Displays the mode and status badges, both teams' large scores (the winner
/// tinted green), and a winner banner once the game is complete.
struct GameInfoCard: View {
    /// The game to summarize.
    let game: GameSession

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(game.gameMode.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Capsule())

                Spacer()

                StatusBadge(status: game.status)
            }

            if let team1 = game.team1, let team2 = game.team2 {
                HStack(alignment: .center, spacing: 20) {
                    VStack(spacing: 4) {
                        Text(team1.displayName)
                            .font(.headline)
                        Text("\(team1.currentScore)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(game.winningTeam == 1 ? .green : .primary)
                    }
                    .frame(maxWidth: .infinity)

                    Text("VS")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 4) {
                        Text(team2.displayName)
                            .font(.headline)
                        Text("\(team2.currentScore)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(game.winningTeam == 2 ? .green : .primary)
                    }
                    .frame(maxWidth: .infinity)
                }

                if let winner = game.winner {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("Winner: \(winner.displayName)")
                            .font(.headline)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    GameInfoCard(game: GameSession(
        gameMode: .twoVsTwo,
        team1: Team(player1Name: "Alice", player2Name: "Bob"),
        team2: Team(player1Name: "Charlie", player2Name: "David")
    ))
    .padding()
}
