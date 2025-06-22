//
//  NewGameView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import SwiftUI

struct NewGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var team1 = ""
    @State private var team2 = ""

    var onCreate: (_ team1: String, _ team2: String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Team 1") {
                    TextField("Enter name", text: $team1)
                }
                Section("Team 2") {
                    TextField("Enter name", text: $team2)
                }
            }
            .navigationTitle("New Game")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        if !team1.isEmpty && !team2.isEmpty {
                            onCreate(team1, team2)
                            dismiss()
                        }
                    }
                    .disabled(team1.isEmpty || team2.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    NewGameView { team1, team2 in
        print("Created game: \(team1) vs \(team2)")
    }
}
