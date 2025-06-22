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
                .onDelete(perform: gameStore.removeGame)
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
                    gameStore.addGame(game: newGame)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
