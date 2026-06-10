# Setup & Troubleshooting

Detailed setup for building DotCounter and enabling iCloud sync. For a feature
overview and architecture, see the [README](../README.md).

## Prerequisites

- Xcode 26+
- iOS / iPadOS 26.2+ target (SwiftData requires iOS 17+; this project targets 26.2)
- An Apple Developer account signed into Xcode (for iCloud/CloudKit)

The project uses an Xcode **synchronized file group**, so source files are picked
up automatically from the folder structure — there is no manual "Add Files to
target" step.

## 1. Build & run locally

1. Open `DotCounter.xcodeproj`.
2. Select an iPhone or iPad simulator.
3. Press **⌘R**. The app launches to the "No Games" empty state.

The app works fully offline; data is stored locally even without iCloud.

## 2. Enable iCloud (one time, for sync)

1. Select the project ▸ the **DotCounter** target ▸ **Signing & Capabilities**.
2. Click **+ Capability** and add **iCloud**.
3. Under iCloud, check **CloudKit**. Xcode provisions the container automatically.

The container identifier is already declared in `DotCounter/DotCounter.entitlements`.
SwiftData drives the sync via `cloudKitDatabase: .automatic` — no extra code needed.

## 3. Test iCloud sync (physical devices only)

> iCloud sync does **not** work in the iOS Simulator — use real hardware.

1. Run on a physical iPhone or iPad signed into iCloud.
2. Create a game; wait ~10–30 seconds.
3. Open the app on a second device with the **same Apple ID** — the game appears.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Cannot find type 'GameSession' in scope` | Clean the build folder (⇧⌘K) and rebuild; confirm the file is under the synchronized `DotCounter/` source folder. |
| iCloud not syncing | Verify the CloudKit capability is enabled, you're signed into iCloud, you're on a real device (not the Simulator), and allow time for the first sync. |
| Build errors mentioning SwiftData | Ensure the deployment target is iOS 17+ (project default 26.2) and you're on Xcode 26+. |
| App crashes on launch | Check the console (⇧⌘Y) for the `ModelContainer` error; clean (⇧⌘K) and rebuild. |

## CloudKit Dashboard (optional)

To inspect synced records, sign in at
[icloud.developer.apple.com](https://icloud.developer.apple.com), select the
container, and browse record types and records to debug sync issues.
