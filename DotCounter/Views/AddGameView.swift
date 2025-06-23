//
//  AddGameView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import SwiftUI

struct AddGameView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: GameStore
    @State private var team1Name = ""
    @State private var team2Name = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Team Names")) {
                    TextField("Team 1 Name", text: $team1Name)
                    TextField("Team 2 Name", text: $team2Name)
                }
            }
            .navigationTitle("New Game")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create Game") {
                        store.addGame(team1Name: team1Name, team2Name: team2Name)
                        dismiss()
                    }
                    .disabled(team1Name == "" || team2Name == "")
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AddGameView(store: GameStore())
}
