//
//  GameDetailView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI
import SwiftData

/// The active-game screen where scores are added and the game is ended.
///
/// Adapts its layout to the horizontal size class: a stacked layout on iPhone
/// (compact) and a side-by-side layout on iPad (regular). Hosts the score
/// controls (``CompactTeamSection``), the score header/card, and the toolbar
/// actions for ending or reopening a game.
struct GameDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var game: GameSession
    @State private var showingEndGameAlert = false
    @State private var showingWinnerAlert = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if let team1 = game.team1, let team2 = game.team2 {
                if horizontalSizeClass == .regular {
                    // iPad layout - side by side
                    iPadLayout(team1: team1, team2: team2)
                } else {
                    // iPhone layout - stacked
                    iPhoneLayout(team1: team1, team2: team2)
                }
            } else {
                Text("Error: Game data is corrupted")
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Domino Score")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if game.status == .active {
                    Button {
                        showingEndGameAlert = true
                    } label: {
                        Image(systemName: "stop.circle.fill")
                            .foregroundStyle(.red)
                            .font(.title3)
                    }
                } else if game.canReopen {
                    Button {
                        game.reopen()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                            Text("Undo")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.orange)
                    }
                }
            }
        }
        .alert("End Game", isPresented: $showingEndGameAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Game", role: .destructive) {
                endGame()
            }
        } message: {
            Text("Are you sure you want to end this game?")
        }
        .alert("Winner!", isPresented: $showingWinnerAlert) {
            Button("OK") { }
        } message: {
            if let winner = game.winner {
                Text("\(winner.displayName) wins!")
            }
        }
    }

    /// Stacked layout used on iPhone: compact header above the two team sections.
    /// - Parameters:
    ///   - team1: The first team (non-optional after the guard in `body`).
    ///   - team2: The second team.
    func iPhoneLayout(team1: Team, team2: Team) -> some View {
        VStack(spacing: 0) {
            // Compact score header
            CompactScoreHeader(game: game)
                .padding()
                .background(Color(.systemGroupedBackground))

            Divider()

            // Team sections - no scrolling needed
            VStack(spacing: 0) {
                CompactTeamSection(
                    team: team1,
                    teamNumber: 1,
                    isActive: game.status == .active,
                    onAddScore: { points in
                        addScore(points, to: team1, teamNumber: 1)
                    },
                    onUndo: {
                        team1.undoLastScore()
                    }
                )

                Divider()

                CompactTeamSection(
                    team: team2,
                    teamNumber: 2,
                    isActive: game.status == .active,
                    onAddScore: { points in
                        addScore(points, to: team2, teamNumber: 2)
                    },
                    onUndo: {
                        team2.undoLastScore()
                    }
                )
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    /// Side-by-side layout used on iPad: an info card above two team sections.
    /// - Parameters:
    ///   - team1: The first team.
    ///   - team2: The second team.
    func iPadLayout(team1: Team, team2: Team) -> some View {
        VStack(spacing: 20) {
            GameInfoCard(game: game)
                .padding(.horizontal)

            HStack(spacing: 20) {
                CompactTeamSection(
                    team: team1,
                    teamNumber: 1,
                    isActive: game.status == .active,
                    onAddScore: { points in
                        addScore(points, to: team1, teamNumber: 1)
                    },
                    onUndo: {
                        team1.undoLastScore()
                    }
                )

                Divider()

                CompactTeamSection(
                    team: team2,
                    teamNumber: 2,
                    isActive: game.status == .active,
                    onAddScore: { points in
                        addScore(points, to: team2, teamNumber: 2)
                    },
                    onUndo: {
                        team2.undoLastScore()
                    }
                )
            }
            .padding()
        }
    }

    /// Adds points to a team and triggers an instant win when the +35 button is used.
    ///
    /// The +35 button is an intentional "capot" instant win: it ends the game
    /// for the team that pressed it. Reaching the winning score via smaller
    /// increments does not auto-win.
    ///
    /// - Parameters:
    ///   - points: The points to add.
    ///   - team: The team receiving the points.
    ///   - teamNumber: The team's side, `1` or `2`.
    private func addScore(_ points: Int, to team: Team, teamNumber: Int) {
        team.addScore(points)

        if points == GameSession.winningScore {
            game.recordInstantWin(for: teamNumber)
            showingWinnerAlert = true
        }
    }

    /// Ends the game manually (declaring a winner only if one already reached the
    /// winning score). See ``GameSession/endGame()``.
    private func endGame() {
        game.endGame()
    }
}

#Preview {
    NavigationStack {
        GameDetailView(game: GameSession(
            gameMode: .twoVsTwo,
            team1: Team(player1Name: "Alice", player2Name: "Bob"),
            team2: Team(player1Name: "Charlie", player2Name: "David")
        ))
    }
    .modelContainer(for: GameSession.self, inMemory: true)
}
