//
//  StatusBadge.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI

/// A small capsule badge showing a game's ``GameStatus``.
///
/// Tinted green while active and gray once completed. Shared across the game
/// list and detail screens.
struct StatusBadge: View {
    /// The status to display.
    let status: GameStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status == .active ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
            .foregroundStyle(status == .active ? .green : .secondary)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusBadge(status: .active)
        StatusBadge(status: .completed)
    }
}
