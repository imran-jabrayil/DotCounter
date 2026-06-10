//
//  GameRowView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI

/// A single row in ``GameListView`` summarizing one game.
///
/// Shows the mode and status badges, both teams' names and current scores, the
/// winner (if any), and the creation timestamp.
struct GameRowView: View {
    /// The game to summarize.
    let game: GameSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(game.gameMode.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Capsule())

                Spacer()

                StatusBadge(status: game.status)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.team1?.displayName ?? "Team 1")
                        .font(.headline)
                    Text("\(game.team1?.currentScore ?? 0) points")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("vs")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(game.team2?.displayName ?? "Team 2")
                        .font(.headline)
                    Text("\(game.team2?.currentScore ?? 0) points")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let winner = game.winner {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("Winner: \(winner.displayName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(game.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        GameRowView(game: GameSession(
            gameMode: .twoVsTwo,
            team1: Team(player1Name: "Alice", player2Name: "Bob"),
            team2: Team(player1Name: "Charlie", player2Name: "David")
        ))
    }
}
