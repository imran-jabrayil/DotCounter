//
//  ScoreEntry.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import SwiftUI

struct ScoreEntry: Identifiable, Codable {
    let id = UUID()
    let points: Int
}
