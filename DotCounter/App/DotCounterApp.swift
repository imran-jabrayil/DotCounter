//
//  DotCounterApp.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

import SwiftUI
import SwiftData

/// The app entry point.
///
/// Builds the shared SwiftData ``ModelContainer`` (backed by CloudKit) and
/// presents ``GameListView`` as the root scene.
@main
struct DotCounterApp: App {
    /// The app-wide SwiftData container holding ``GameSession`` and ``Team``,
    /// synced automatically via CloudKit.
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GameSession.self,
            Team.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            GameListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
