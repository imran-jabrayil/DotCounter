//
//  CreateGameView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI
import SwiftData

struct CreateGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameMode: GameMode = .oneVsOne
    @State private var team1Player1 = ""
    @State private var team1Player2 = ""
    @State private var team2Player1 = ""
    @State private var team2Player2 = ""
    
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
    
    private func createGame() {
        let team1 = Team(
            player1Name: team1Player1.trimmingCharacters(in: .whitespaces),
            player2Name: gameMode == .twoVsTwo ? team1Player2.trimmingCharacters(in: .whitespaces) : nil
        )
        
        let team2 = Team(
            player1Name: team2Player1.trimmingCharacters(in: .whitespaces),
            player2Name: gameMode == .twoVsTwo ? team2Player2.trimmingCharacters(in: .whitespaces) : nil
        )
        
        let game = GameSession(gameMode: gameMode, team1: team1, team2: team2)
        
        modelContext.insert(game)
        dismiss()
    }
}

#Preview {
    CreateGameView()
        .modelContainer(for: GameSession.self, inMemory: true)
}
