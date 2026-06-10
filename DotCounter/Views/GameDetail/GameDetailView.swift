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
///
/// All scoring and win detection is delegated to ``GameSession/applyScore(points:toTeam:)``;
/// this view only reacts to the returned ``GameSession/ScoreOutcome`` to present
/// the winner alert, a confetti celebration, and haptic feedback.
struct GameDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var game: GameSession
    @State private var showingEndGameAlert = false
    @State private var showingWinnerAlert = false
    @State private var showCelebration = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Haptic triggers. Each is bumped to fire its associated sensory feedback.
    @State private var scoreFeedback = 0
    @State private var undoFeedback = 0
    @State private var winFeedback = 0

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
        .overlay {
            if showCelebration {
                ConfettiView()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
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
        .sensoryFeedback(.impact(weight: .light), trigger: scoreFeedback)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: undoFeedback)
        .sensoryFeedback(.success, trigger: winFeedback)
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
                    capotEnabled: game.capotInstantWin,
                    onAddScore: { points in
                        addScore(points, toTeam: 1)
                    },
                    onUndo: {
                        undo(team1)
                    }
                )

                Divider()

                CompactTeamSection(
                    team: team2,
                    teamNumber: 2,
                    isActive: game.status == .active,
                    capotEnabled: game.capotInstantWin,
                    onAddScore: { points in
                        addScore(points, toTeam: 2)
                    },
                    onUndo: {
                        undo(team2)
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
                    capotEnabled: game.capotInstantWin,
                    onAddScore: { points in
                        addScore(points, toTeam: 1)
                    },
                    onUndo: {
                        undo(team1)
                    }
                )

                Divider()

                CompactTeamSection(
                    team: team2,
                    teamNumber: 2,
                    isActive: game.status == .active,
                    capotEnabled: game.capotInstantWin,
                    onAddScore: { points in
                        addScore(points, toTeam: 2)
                    },
                    onUndo: {
                        undo(team2)
                    }
                )
            }
            .padding()
        }
    }

    /// Adds points to a team via the model and reacts to the resulting outcome.
    ///
    /// The model applies the game's rules (capot instant win, auto-end at the
    /// target); this view only presents the winner alert + celebration and fires
    /// haptics based on what happened.
    ///
    /// - Parameters:
    ///   - points: The points to add.
    ///   - teamNumber: The team's side, `1` or `2`.
    private func addScore(_ points: Int, toTeam teamNumber: Int) {
        let outcome = game.applyScore(points: points, toTeam: teamNumber)
        switch outcome {
        case .scored:
            scoreFeedback += 1
        case .capotWin, .targetWin:
            winFeedback += 1
            showingWinnerAlert = true
            withAnimation { showCelebration = true }
            // Remove the confetti after it has fallen.
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                withAnimation { showCelebration = false }
            }
        }
    }

    /// Undoes the last score for a team and fires a soft haptic.
    /// - Parameter team: The team whose last score should be reverted.
    private func undo(_ team: Team) {
        guard team.canUndo() else { return }
        team.undoLastScore()
        undoFeedback += 1
    }

    /// Ends the game manually (declaring a winner only if one already reached the
    /// target score). See ``GameSession/endGame()``.
    private func endGame() {
        game.endGame()
        if game.winner != nil {
            winFeedback += 1
            withAnimation { showCelebration = true }
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                withAnimation { showCelebration = false }
            }
        }
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
