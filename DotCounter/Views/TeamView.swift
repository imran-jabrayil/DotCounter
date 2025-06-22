//
//  TeamView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 22.06.25.
//

import SwiftUI

struct TeamView: View {
    let team: String
    let isTeam1: Bool
    @ObservedObject var scoreBinding: ScoreBinding

    private let points: [Int] = [5, 10, 15, 20, 25, 30, 35]

    var score: Int {
        isTeam1 ? scoreBinding.score1 : scoreBinding.score2
    }

    var lastAdded: Int? {
        isTeam1 ? scoreBinding.lastAdded1 : scoreBinding.lastAdded2
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(team):")
                Text("\(score)")
                    .font(.headline)
                if let last = lastAdded {
                    Text("(+\(last))")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                ForEach(points, id: \.self) { value in
                    Button("+\(value)") {
                        if isTeam1 {
                            scoreBinding.add(toTeam1: value)
                        } else {
                            scoreBinding.add(toTeam2: value)
                        }
                    }
                    .padding()
                    .frame(minWidth: 70)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                }

                Button(action: {
                    if isTeam1 {
                        scoreBinding.undoTeam1()
                    } else {
                        scoreBinding.undoTeam2()
                    }
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .padding()
                        .frame(minWidth: 70)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .padding()
    }
}

#Preview {
    let game = Game(team1: "Team A", team2: "Team B", score1: 10, score2: 20)
    let store = GameStore()
    let binding = ScoreBinding(game: game, store: store)

    TeamView(team: "Team A", isTeam1: true, scoreBinding: binding)
}
