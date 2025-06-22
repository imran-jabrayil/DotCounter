//
//  GameStore.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import Foundation
import Combine


class GameStore: ObservableObject {
    @Published var games: [Game] = []
    
    private let key = "dotcounter_key"
    private var store: NSUbiquitousKeyValueStore
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        store = NSUbiquitousKeyValueStore.default
        loadGames()
        
        NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
            .sink { [weak self] _ in
                self?.loadGames()
            }
            .store(in: &cancellables)
    }
    
    func addGame(game: Game) {
        games.append(game)
        saveGames()
    }
    
    func removeGame(at offsets: IndexSet) {
        games.remove(atOffsets: offsets)
        saveGames()
    }
    
    private func saveGames() {
        if let data = try? JSONEncoder().encode(games) {
            store.set(data, forKey: key)
            store.synchronize()
        }
    }
    
    private func loadGames() {
        guard let data = store.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Game].self, from: data) else {
            return
        }
        DispatchQueue.main.async {
            self.games = decoded
        }
    }
}
