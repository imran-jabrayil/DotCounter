//
//  GameListView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI
import SwiftData

/// The root screen: a list of all games, newest first.
///
/// Each row navigates to ``GameDetailView``. Provides creation (via a
/// ``CreateGameView`` sheet), swipe/edit deletion, and an empty state. The list
/// updates reactively through `@Query`, including from CloudKit sync.
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

    /// Deletes the games at the given list offsets from the model context.
    /// - Parameter offsets: Index set provided by `onDelete`.
    private func deleteGames(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(games[index])
        }
    }
}

#Preview {
    GameListView()
        .modelContainer(for: GameSession.self, inMemory: true)
}
