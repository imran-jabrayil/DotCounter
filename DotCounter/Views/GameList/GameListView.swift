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
/// Uses a `NavigationSplitView` so iPad shows the game list and the selected
/// game side-by-side, while iPhone collapses to a pushed stack. Provides
/// creation (via a ``CreateGameView`` sheet), settings (via a ``SettingsView``
/// sheet), swipe/edit deletion, and an empty state. On first launch it presents
/// ``OnboardingView`` until the user has completed it. The list updates
/// reactively through `@Query`, including from CloudKit sync.
struct GameListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameSession.createdAt, order: .reverse) private var games: [GameSession]
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    @State private var showingCreateGame = false
    @State private var showingSettings = false
    @State private var selectedGame: GameSession?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedGame) {
                ForEach(games) { game in
                    NavigationLink(value: game) {
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
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
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
        } detail: {
            if let selectedGame {
                GameDetailView(game: selectedGame)
            } else {
                ContentUnavailableView(
                    "Select a Game",
                    systemImage: "die.face.5",
                    description: Text("Choose a game from the list to track its score.")
                )
            }
        }
        .sheet(isPresented: $showingCreateGame) {
            CreateGameView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: Binding(
            get: { !hasCompletedOnboarding },
            set: { _ in } // Dismissal is driven by OnboardingView setting the flag.
        )) {
            OnboardingView()
        }
    }

    /// Deletes the games at the given list offsets from the model context.
    /// Clears the selection if the selected game was removed.
    /// - Parameter offsets: Index set provided by `onDelete`.
    private func deleteGames(at offsets: IndexSet) {
        for index in offsets {
            let game = games[index]
            if game == selectedGame {
                selectedGame = nil
            }
            modelContext.delete(game)
        }
    }
}

#Preview {
    GameListView()
        .modelContainer(for: GameSession.self, inMemory: true)
}
