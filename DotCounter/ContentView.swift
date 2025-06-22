//
//  ContentView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 22.06.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameStore: GameStore = GameStore()
    @State private var showNewGameSheet: Bool = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(gameStore.games) { game in
                    NavigationLink("\(game.team1) vs \(game.team2)") {
                        let binding = ScoreBinding(game: game, store: gameStore)
                        GameView(scoreBinding: binding, team1Name: game.team1, team2Name: game.team2)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let game = gameStore.games[index]
                        gameStore.removeGame(game)
                    }
                }
            }
            .refreshable {
                gameStore.fetchGames()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            .navigationTitle("Games")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewGameSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewGameSheet) {
                NewGameView { team1, team2 in
                    let newGame = Game(team1: team1, team2: team2)
                    gameStore.addGame(newGame)
                }
            }
        }
        .onAppear {
            gameStore.fetchGames()
        }
    }
}

#Preview {
    ContentView()
}
