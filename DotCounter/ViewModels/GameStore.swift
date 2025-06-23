//
//  GameStore.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import Foundation

class GameStore: ObservableObject {
    @Published var games: [Game] = [] {
        didSet {
            saveGames()
        }
    }
    
    private let userDefaultsKey = "DominoScorerGames"

    init() {
        loadGames()
    }
    
    var sortedGames: [Game] {
        games.sorted { $0.createdAt > $1.createdAt }
    }

    func addGame(team1Name: String, team2Name: String) {
        let newGame = Game(team1Name: team1Name, team2Name: team2Name)
        games.append(newGame)
    }

    func delete(at offsets: IndexSet) {
        let idsToDelete = offsets.map { sortedGames[$0].id }
        games.removeAll { idsToDelete.contains($0.id) }
    }
    
    private func saveGames() {
        if let encodedData = try? JSONEncoder().encode(games) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
    
    private func loadGames() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decodedGames = try? JSONDecoder().decode([Game].self, from: savedData) {
                self.games = decodedGames
                return
            }
        }
        self.games = []
    }
}
