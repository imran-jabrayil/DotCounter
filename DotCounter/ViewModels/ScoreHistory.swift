//
//  ScoreHistory.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 22.06.25.
//

import Foundation

class ScoreHistory : ObservableObject {
    @Published private(set) var score: Int = 0
    @Published private(set) var lastAction: Int? = nil;
    private var history: [Int] = []
    
    func addScore(_ newScore: Int) {
        score += newScore
        history.append(newScore)
        lastAction = history.last
    }
    
    func undoLast() {
        guard let last = history.popLast() else { return }
        score -= last
        lastAction = history.last
    }
}
