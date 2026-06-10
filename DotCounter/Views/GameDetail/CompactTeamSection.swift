//
//  CompactTeamSection.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI

/// The scoring controls for a single team within ``GameDetailView``.
///
/// Renders the team header with an inline undo button, a grid of quick-add
/// score buttons (the +35 button is highlighted as the green "capot" instant
/// win only when that rule is enabled), and a horizontally scrolling
/// score-history timeline that auto-scrolls to the latest entry. Designed to
/// fit on screen without vertical scrolling.
struct CompactTeamSection: View {
    /// The team whose score is shown and edited.
    let team: Team
    /// The team's side, `1` or `2`, shown in the header.
    let teamNumber: Int
    /// Whether scoring controls are enabled (only while the game is active).
    let isActive: Bool
    /// Whether the +35 "capot" instant-win rule is in force for this game.
    /// When `false`, the +35 button looks and behaves like any other score.
    let capotEnabled: Bool
    /// Called with the chosen point value when a score button is tapped.
    let onAddScore: (Int) -> Void
    /// Called when the inline undo button is tapped.
    let onUndo: () -> Void

    /// The quick-add point values offered as buttons. `35` is the capot move.
    let scoreOptions = [5, 10, 15, 20, 25, 30, 35]

    /// Whether the given score button is the highlighted capot instant-win.
    private func isCapotButton(_ score: Int) -> Bool {
        capotEnabled && score == GameSession.capotValue
    }

    var body: some View {
        VStack(spacing: 12) {
            // Minimal header
            HStack {
                Text("Team \(teamNumber): \(team.displayName)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                // Undo button inline
                if isActive {
                    Button {
                        onUndo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.caption)
                            .foregroundStyle(team.canUndo() ? .red : .secondary)
                            .padding(8)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Circle())
                    }
                    .disabled(!team.canUndo())
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            // Compact button grid
            if isActive {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(scoreOptions, id: \.self) { score in
                        Button {
                            onAddScore(score)
                        } label: {
                            Text("+\(score)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isCapotButton(score) ? Color.green : Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }

            // Compact score history with auto-scroll
            if !team.scoreHistory.isEmpty {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(team.scoreHistory.enumerated()), id: \.offset) { index, score in
                                Text("\(score)")
                                    .font(.caption)
                                    .foregroundStyle(index == team.scoreHistory.count - 1 ? .primary : .secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        index == team.scoreHistory.count - 1 ?
                                        Color.blue.opacity(0.2) : Color(.tertiarySystemGroupedBackground)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .id(index)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: team.scoreHistory.count) { _, newValue in
                        // Scroll to the last item when the count changes. A short
                        // delay lets the new item lay out so the animation lands on
                        // it for both add and undo.
                        guard newValue > 0 else { return }
                        Task {
                            try? await Task.sleep(for: .seconds(0.3))
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(newValue - 1, anchor: .trailing)
                            }
                        }
                    }
                    .onAppear {
                        // Scroll to the last item on appear
                        if !team.scoreHistory.isEmpty {
                            proxy.scrollTo(team.scoreHistory.count - 1, anchor: .trailing)
                        }
                    }
                }
            }

            Spacer()
                .frame(height: 12)
        }
        .background(Color(.secondarySystemGroupedBackground))
    }
}

#Preview {
    CompactTeamSection(
        team: Team(player1Name: "Alice", player2Name: "Bob"),
        teamNumber: 1,
        isActive: true,
        capotEnabled: true,
        onAddScore: { _ in },
        onUndo: { }
    )
}
