//
//  CompactScoreHeader.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI

/// A space-efficient score header used at the top of the iPhone layout.
///
/// Shows both teams' names and scores (winner tinted green) with the mode and
/// status in between, plus a compact winner line once the game is complete.
struct CompactScoreHeader: View {
    /// The game to summarize.
    let game: GameSession

    var body: some View {
        VStack(spacing: 8) {
            if let team1 = game.team1, let team2 = game.team2 {
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text(team1.displayName)
                            .font(.caption)
                            .lineLimit(1)
                        Text("\(team1.currentScore)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(game.winningTeam == 1 ? .green : .primary)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 4) {
                        Text(game.gameMode.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("VS")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        StatusBadge(status: game.status)
                    }

                    VStack(spacing: 2) {
                        Text(team2.displayName)
                            .font(.caption)
                            .lineLimit(1)
                        Text("\(team2.currentScore)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(game.winningTeam == 2 ? .green : .primary)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Winner badge if game is complete
                if let winner = game.winner {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text("Winner: \(winner.displayName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    CompactScoreHeader(game: GameSession(
        gameMode: .oneVsOne,
        team1: Team(player1Name: "Alice"),
        team2: Team(player1Name: "Bob")
    ))
    .padding()
}
