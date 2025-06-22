//
//  ScoreBinding.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import SwiftUI
import Combine

class ScoreBinding: ObservableObject {
    @Published var score1: Int
    @Published var score2: Int
    private let gameID: UUID
    private let store: GameStore

    init(game: Game, store: GameStore) {
        self.score1 = game.score1
        self.score2 = game.score2
        self.gameID = game.id
        self.store = store

        $score1
            .combineLatest($score2)
            .receive(on: DispatchQueue.main) // Prevent background thread issues
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main) // Prevent too frequent updates
            .sink { [weak self] s1, s2 in
                guard let self else { return }
                self.store.updateScore(for: self.gameID, score1: s1, score2: s2)
            }
            .store(in: &cancellables)

    }

    private var cancellables = Set<AnyCancellable>()
}
