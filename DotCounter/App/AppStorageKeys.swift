//
//  AppStorageKeys.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 10.06.26.
//

import Foundation

/// Stable `UserDefaults` keys shared by onboarding, settings, and game creation.
///
/// Centralising the key strings here avoids typo'd duplicate literals across the
/// `@AppStorage` declarations in `OnboardingView`, `SettingsView`, and
/// `CreateGameView`. These store the user's *global default* rules; each game
/// snapshots them at creation, so editing them never affects existing games.
///
/// - Note: `@AppStorage` is backed by `UserDefaults`, which is per-device. If
///   cross-device sync of these defaults is desired later, layer
///   `NSUbiquitousKeyValueStore` on top — the keys defined here would be reused.
enum AppStorageKeys {
    /// Whether the first-launch onboarding has been completed. `Bool`, default `false`.
    static let hasCompletedOnboarding = "hasCompletedOnboarding"

    /// Default for ``GameSession/capotInstantWin``. `Bool`, default `true`.
    static let defaultCapotInstantWin = "defaultCapotInstantWin"

    /// Default for ``GameSession/autoEndAtTarget``. `Bool`, default `true`.
    static let defaultAutoEndAtTarget = "defaultAutoEndAtTarget"
}
