//
//  SettingsView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 10.06.26.
//

import SwiftUI

/// Edits the global default house rules used when creating new games.
///
/// Presented as a sheet from ``GameListView``. The toggles bind directly to the
/// shared `@AppStorage` keys, so edits persist immediately. Because each game
/// snapshots the rules at creation (see ``CreateGameView``), changes here only
/// affect *future* games — games already in progress keep their own rules.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(AppStorageKeys.defaultCapotInstantWin) private var defaultCapotInstantWin = true
    @AppStorage(AppStorageKeys.defaultAutoEndAtTarget) private var defaultAutoEndAtTarget = true
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Instant capot win", isOn: $defaultCapotInstantWin)
                    Toggle("Finish on \(GameSession.defaultTargetScore) automatically", isOn: $defaultAutoEndAtTarget)
                } header: {
                    Text("Default Rules")
                } footer: {
                    Text("Changes apply to new games only. Games already in progress keep the rules they started with.")
                }

                Section {
                    Button("Show Intro Again") {
                        hasCompletedOnboarding = false
                        dismiss()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
