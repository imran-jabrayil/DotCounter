//
//  GameDetailView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI
import SwiftData

struct GameDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var game: GameSession
    @State private var showingEndGameAlert = false
    @State private var showingWinnerAlert = false
    @State private var winningTeamNumber: Int?
    @State private var wasAutoCompleted = false
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
                } else if wasAutoCompleted {
                    Button {
                        uncompleteGame()
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
            if let winner = winningTeamNumber, let team1 = game.team1, let team2 = game.team2 {
                Text("\(winner == 1 ? team1.displayName : team2.displayName) wins with 35+ points!")
            }
        }
    }
    
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
    
    private func addScore(_ points: Int, to team: Team, teamNumber: Int) {
        team.addScore(points)
        
        // Only auto-complete if +35 button was clicked
        if points == 35 {
            winningTeamNumber = teamNumber
            game.winningTeam = teamNumber
            game.endGame()
            wasAutoCompleted = true
            showingWinnerAlert = true
        }
    }
    
    private func endGame() {
        game.endGame()
        wasAutoCompleted = false
    }
    
    private func uncompleteGame() {
        // Reactivate the game
        game.status = .active
        game.winningTeam = nil
        wasAutoCompleted = false
        
        // Remove the last score (which was 35) from the winning team
        if let winner = winningTeamNumber {
            let team = winner == 1 ? game.team1 : game.team2
            team?.undoLastScore()
        }
        winningTeamNumber = nil
    }
}

struct GameInfoCard: View {
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
                
                if let winner = game.winningTeam {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("Winner: \(winner == 1 ? team1.displayName : team2.displayName)")
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

// Compact score header for iPhone - minimal space
struct CompactScoreHeader: View {
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
                if let winner = game.winningTeam {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text("Winner: \(winner == 1 ? team1.displayName : team2.displayName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

// Compact team section - fits on screen without scrolling
struct CompactTeamSection: View {
    let team: Team
    let teamNumber: Int
    let isActive: Bool
    let onAddScore: (Int) -> Void
    let onUndo: () -> Void
    
    let scoreOptions = [5, 10, 15, 20, 25, 30, 35]
    
    var body: some View {
        VStack(spacing: 12) {
            // Minimal header
            HStack {
                Text("Team \(teamNumber): \(team.displayName)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // Undo button inline
                if isActive {
                    Button {
                        onUndo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.caption)
                            .foregroundStyle(team.canUndo() ? .red : .secondary)
                            .padding(8)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Circle())
                    }
                    .disabled(!team.canUndo())
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Compact button grid
            if isActive {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(scoreOptions, id: \.self) { score in
                        Button {
                            onAddScore(score)
                        } label: {
                            Text("+\(score)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(score == 35 ? Color.green : Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            
            // Compact score history with auto-scroll
            if !team.scoreHistory.isEmpty {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(team.scoreHistory.enumerated()), id: \.offset) { index, score in
                                Text("\(score)")
                                    .font(.caption)
                                    .foregroundStyle(index == team.scoreHistory.count - 1 ? .primary : .secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        index == team.scoreHistory.count - 1 ?
                                        Color.blue.opacity(0.2) : Color(.tertiarySystemGroupedBackground)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .id(index)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: team.scoreHistory.count) { oldValue, newValue in
                        // Scroll to the last item when count changes
                        if newValue > 0 {
                            // Small delay ensures animation works properly for both add and undo
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(newValue - 1, anchor: .trailing)
                                }
                            }
                        }
                    }
                    .onAppear {
                        // Scroll to the last item on appear
                        if !team.scoreHistory.isEmpty {
                            proxy.scrollTo(team.scoreHistory.count - 1, anchor: .trailing)
                        }
                    }
                }
            }
            
            Spacer()
                .frame(height: 12)
        }
        .background(Color(.secondarySystemGroupedBackground))
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
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
