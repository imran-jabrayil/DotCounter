//
//  OnboardingView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 10.06.26.
//

import SwiftUI

/// First-launch screen that introduces the app and captures the two house rules
/// as global defaults.
///
/// Presented as a full-screen cover from ``GameListView`` while
/// ``AppStorageKeys/hasCompletedOnboarding`` is `false`. The toggles are seeded
/// from (and saved back to) the same default keys that ``SettingsView`` and
/// ``CreateGameView`` read, so the choices made here become the defaults for new
/// games. Tapping *Get Started* persists the choices and marks onboarding done,
/// which dismisses the cover. Resetting the flag re-presents this screen.
struct OnboardingView: View {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(AppStorageKeys.defaultCapotInstantWin) private var defaultCapotInstantWin = true
    @AppStorage(AppStorageKeys.defaultAutoEndAtTarget) private var defaultAutoEndAtTarget = true

    // Local edits, seeded from the stored defaults and committed on "Get Started".
    @State private var capotInstantWin = true
    @State private var autoEndAtTarget = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    rulesCard

                    Text("You can change these any time in Settings. Each game keeps the rules it was created with.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    commit()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .background(.bar)
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Seed local toggles from the stored defaults.
            capotInstantWin = defaultCapotInstantWin
            autoEndAtTarget = defaultAutoEndAtTarget
        }
    }

    /// App intro: icon + one-line description of what the app does.
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "die.face.5.fill")
                .font(.system(size: 52))
                .foregroundStyle(.tint)

            Text("DotCounter keeps score for your domino games.")
                .font(.title3)
                .fontWeight(.semibold)

            Text("First, pick the house rules. The first team to \(GameSession.defaultTargetScore) points wins.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    /// The two configurable house rules, each with a short explanation.
    private var rulesCard: some View {
        VStack(spacing: 0) {
            ruleToggle(
                isOn: $capotInstantWin,
                title: "Instant capot win",
                detail: "Pressing +35 wins the game immediately. Turn off to make +35 a normal move."
            )

            Divider().padding(.leading)

            ruleToggle(
                isOn: $autoEndAtTarget,
                title: "Finish on \(GameSession.defaultTargetScore) automatically",
                detail: "End the game the moment a team reaches \(GameSession.defaultTargetScore). Turn off to finish the round and end manually."
            )
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// A single rule row: a bold title, a description, and a trailing toggle.
    private func ruleToggle(isOn: Binding<Bool>, title: String, detail: String) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    /// Persists the chosen defaults and marks onboarding complete (dismisses).
    private func commit() {
        defaultCapotInstantWin = capotInstantWin
        defaultAutoEndAtTarget = autoEndAtTarget
        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView()
}
