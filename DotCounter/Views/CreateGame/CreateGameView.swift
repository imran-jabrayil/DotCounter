//
//  CreateGameView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI
import SwiftData

/// Modal form for creating a new game.
///
/// Lets the user pick the ``GameMode`` and enter player names for both teams,
/// then inserts a new ``GameSession`` into the model context. The current global
/// default rules are *snapshotted* onto the new game, so later changes in
/// ``SettingsView`` never alter this game. The Create button is disabled until
/// all required names are filled in.
struct CreateGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Global default rules, snapshotted onto each new game at creation.
    @AppStorage(AppStorageKeys.defaultCapotInstantWin) private var defaultCapotInstantWin = true
    @AppStorage(AppStorageKeys.defaultAutoEndAtTarget) private var defaultAutoEndAtTarget = true

    @State private var gameMode: GameMode = .oneVsOne
    @State private var team1Player1 = ""
    @State private var team1Player2 = ""
    @State private var team2Player1 = ""
    @State private var team2Player2 = ""

    /// Whether the form has enough valid input to create a game.
    ///
    /// Requires player 1 on both teams, plus player 2 on both teams when in
    /// 2v2 mode. Whitespace-only names do not count.
    var canCreateGame: Bool {
        let team1Valid = !team1Player1.trimmingCharacters(in: .whitespaces).isEmpty &&
                        (gameMode == .oneVsOne || !team1Player2.trimmingCharacters(in: .whitespaces).isEmpty)
        let team2Valid = !team2Player1.trimmingCharacters(in: .whitespaces).isEmpty &&
                        (gameMode == .oneVsOne || !team2Player2.trimmingCharacters(in: .whitespaces).isEmpty)
        return team1Valid && team2Valid
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Game Mode", selection: $gameMode) {
                        Text("1v1").tag(GameMode.oneVsOne)
                        Text("2v2").tag(GameMode.twoVsTwo)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Game Mode")
                }

                Section {
                    TextField("Player 1", text: $team1Player1)
                        .textContentType(.name)

                    if gameMode == .twoVsTwo {
                        TextField("Player 2", text: $team1Player2)
                            .textContentType(.name)
                    }
                } header: {
                    Text("Team 1")
                }

                Section {
                    TextField("Player 1", text: $team2Player1)
                        .textContentType(.name)

                    if gameMode == .twoVsTwo {
                        TextField("Player 2", text: $team2Player2)
                            .textContentType(.name)
                    }
                } header: {
                    Text("Team 2")
                }

                Section {
                    Label {
                        Text(ruleSummary)
                    } icon: {
                        Image(systemName: "checkmark.seal")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                } header: {
                    Text("Rules")
                } footer: {
                    Text("Set the defaults in Settings.")
                }
            }
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGame()
                    }
                    .disabled(!canCreateGame)
                }
            }
        }
    }

    /// A short, human-readable summary of the rules this game will use.
    private var ruleSummary: String {
        let target = GameSession.defaultTargetScore
        let capot = defaultCapotInstantWin ? "+35 wins instantly" : "+35 is a normal move"
        let end = defaultAutoEndAtTarget ? "auto-ends at \(target)" : "ends manually"
        return "First to \(target) — \(capot); \(end)."
    }

    /// Builds the two teams from the trimmed field values, snapshots the current
    /// default rules onto a new ``GameSession``, inserts it, and dismisses.
    private func createGame() {
        let team1 = Team(
            player1Name: team1Player1.trimmingCharacters(in: .whitespaces),
            player2Name: gameMode == .twoVsTwo ? team1Player2.trimmingCharacters(in: .whitespaces) : nil
        )

        let team2 = Team(
            player1Name: team2Player1.trimmingCharacters(in: .whitespaces),
            player2Name: gameMode == .twoVsTwo ? team2Player2.trimmingCharacters(in: .whitespaces) : nil
        )

        let game = GameSession(
            gameMode: gameMode,
            team1: team1,
            team2: team2,
            capotInstantWin: defaultCapotInstantWin,
            autoEndAtTarget: defaultAutoEndAtTarget
        )

        modelContext.insert(game)
        dismiss()
    }
}

#Preview {
    CreateGameView()
        .modelContainer(for: GameSession.self, inMemory: true)
}
