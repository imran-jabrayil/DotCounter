//
//  GameListView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI
import SwiftData

struct GameListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameSession.createdAt, order: .reverse) private var games: [GameSession]
    @State private var showingCreateGame = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(games) { game in
                    NavigationLink {
                        GameDetailView(game: game)
                    } label: {
                        GameRowView(game: game)
                    }
                }
                .onDelete(perform: deleteGames)
            }
            .navigationTitle("Domino Games")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateGame = true
                    } label: {
                        Label("New Game", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingCreateGame) {
                CreateGameView()
            }
            .overlay {
                if games.isEmpty {
                    ContentUnavailableView {
                        Label("No Games", systemImage: "gamecontroller")
                    } description: {
                        Text("Create a new game to start tracking scores")
                    } actions: {
                        Button("Create Game") {
                            showingCreateGame = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
    
    private func deleteGames(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(games[index])
        }
    }
}

struct GameRowView: View {
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
            
            if let winner = game.winningTeam, let team1 = game.team1, let team2 = game.team2 {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("Winner: \(winner == 1 ? team1.displayName : team2.displayName)")
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

struct StatusBadge: View {
    let status: GameStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status == .active ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
            .foregroundStyle(status == .active ? .green : .secondary)
            .clipShape(Capsule())
    }
}

#Preview {
    GameListView()
        .modelContainer(for: GameSession.self, inMemory: true)
}
