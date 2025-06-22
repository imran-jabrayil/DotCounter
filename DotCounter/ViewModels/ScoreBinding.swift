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
    @Published var lastAdded1: Int?
    @Published var lastAdded2: Int?

    private let gameID: UUID
    private let store: GameStore
    private var history1: [Int] = []
    private var history2: [Int] = []

    init(game: Game, store: GameStore) {
        self.score1 = game.score1
        self.score2 = game.score2
        self.gameID = game.id
        self.store = store

        $score1
            .combineLatest($score2)
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] s1, s2 in
                self?.store.updateScore(for: self!.gameID, score1: s1, score2: s2)
            }
            .store(in: &cancellables)
    }

    func add(toTeam1 value: Int) {
        history1.append(value)
        lastAdded1 = value
        score1 += value
    }

    func add(toTeam2 value: Int) {
        history2.append(value)
        lastAdded2 = value
        score2 += value
    }

    func undoTeam1() {
        guard let last = history1.popLast() else { return }
        score1 -= last
        lastAdded1 = history1.last
    }

    func undoTeam2() {
        guard let last = history2.popLast() else { return }
        score2 -= last
        lastAdded2 = history2.last
    }

    private var cancellables = Set<AnyCancellable>()
}
