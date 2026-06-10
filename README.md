# DotCounter — Domino Score Tracker

A native iOS/iPadOS app built with SwiftUI and SwiftData for tracking scores in
domino games, with support for 1v1 and 2v2 matches and iCloud sync.

## Features

- **1v1 and 2v2 games** with custom player names per team.
- **Quick-add scoring** (+5 … +35) with per-team, fully-undoable score history.
- **+35 "capot" instant win** — pressing +35 ends the game for that team. Reaching
  35+ with smaller increments does *not* auto-win. An accidental instant win can be
  reopened from the game screen.
- **Manual end-game** with confirmation; winner shown when a team has reached 35+.
- **Game list** with status badges, winner banner, swipe/edit delete, and an empty state.
- **Adaptive layout** — stacked on iPhone, side-by-side on iPad (horizontal size class).
- **iCloud sync** via SwiftData + CloudKit (`cloudKitDatabase: .automatic`).

## Architecture

The app is intentionally **SwiftData-idiomatic**: views observe the model directly
through `@Query` and `@Bindable` — there is no separate view-model layer — and all
game rules live on the model types.

```
DotCounter/
├── App/          DotCounterApp        — entry point, builds the ModelContainer
├── Models/       GameSession, Team, GameMode, GameStatus
├── Views/
│   ├── GameList/    GameListView, GameRowView
│   ├── GameDetail/  GameDetailView, GameInfoCard, CompactScoreHeader, CompactTeamSection
│   └── CreateGame/  CreateGameView
├── Components/   StatusBadge          — shared badge
└── DotCounter.docc/                    — DocC documentation catalog
```

Full API documentation and architecture diagrams live in the **DocC catalog**
(`DotCounter.docc`): in Xcode, **Product ▸ Build Documentation** (⌃⌥⌘D).

## Usage

- **Create a game:** tap **+**, choose 1v1/2v2, enter names, tap **Create**.
- **Score:** open a game and tap the point buttons. Tap **+35** for an instant win;
  if mistaken, tap **Undo** in the toolbar to reopen the game.
- **Undo a score:** tap a team's undo button (disabled at the starting 0).
- **End a game:** tap the stop button in the toolbar and confirm.
- **Delete:** swipe a row, or use **Edit** for multi-select.

## Requirements

- iOS / iPadOS **26.2+**
- Xcode **26+**

## Setup

iCloud sync requires a one-time capability setup and a physical device — see
[`docs/SETUP.md`](docs/SETUP.md). For a quick local run, just open the project and
run (⌘R); the app works offline and stores data locally.

## License

Copyright © 2026 Imran Jabrayilov. All rights reserved.
