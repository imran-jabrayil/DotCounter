# Architecture

How DotCounter is structured: navigation, data model, and the scoring flow.

## Overview

DotCounter is a small, idiomatic SwiftData + SwiftUI app. There is no view-model
layer — views observe the model directly through `@Query` and `@Bindable`, and
all game rules live on the model types (``GameSession`` and ``Team``).

## Source layout

```
DotCounter/
├── App/          DotCounterApp — entry point, builds the ModelContainer
├── Models/       GameSession, Team, GameMode, GameStatus
├── Views/
│   ├── GameList/    GameListView, GameRowView
│   ├── GameDetail/  GameDetailView, GameInfoCard, CompactScoreHeader, CompactTeamSection
│   └── CreateGame/  CreateGameView
├── Components/   StatusBadge (shared)
└── DotCounter.docc/  this documentation catalog
```

## Navigation flow

```
DotCounterApp (ModelContainer + CloudKit)
        │
        ▼
GameListView ──[+]──▶ CreateGameView (sheet)
        │
        └──[tap game]──▶ GameDetailView (scoring screen)
```

- ``GameListView`` lists every ``GameSession`` newest-first via `@Query`.
- ``CreateGameView`` inserts a new game into the `modelContext`.
- ``GameDetailView`` edits a `@Bindable` game; changes auto-save and sync.

## Data model

```
GameSession
 ├─ id, createdAt, gameMode, status, winningTeam?, wonByInstantWin
 ├─ team1: Team   (cascade delete)
 └─ team2: Team   (cascade delete)

Team
 ├─ player1Name, player2Name?
 └─ scoreHistory: [Int]   // cumulative, starts at [0]
```

Relationships are optional and every property has a default value, as required
for CloudKit-backed SwiftData models. A team's ``Team/currentScore`` is the last
entry of ``Team/scoreHistory``, which makes undo a simple `removeLast`.

## Scoring & win flow

```
User taps +N on a team
        │
        ▼
GameDetailView.addScore(N, team, side)
        │
        ▼
team.addScore(N)            // appends currentScore + N to scoreHistory
        │
        ▼
Was the +35 (capot) button used?
        ├─ No  → nothing else; SwiftData auto-saves, CloudKit syncs
        └─ Yes → game.recordInstantWin(for: side)  // winner = triggering team
                 → status = .completed, show "Winner!" alert
```

The winner is the team that pressed +35 — it is deliberately not re-derived from
the scores, so an opponent already at 35 cannot steal the win. A completed
instant-win game reports ``GameSession/canReopen`` and can be undone with
``GameSession/reopen()``, which removes the +35 entry and reactivates the game.

Ending a game manually via the toolbar calls ``GameSession/endGame()``, which
declares a winner only if a team has already reached
``GameSession/winningScore`` (otherwise the game ends with no winner).

## Undo flow

```
User taps the team's undo button
        │
        ▼
team.undoLastScore()        // removeLast, but never below the starting [0]
        │
        ▼
currentScore recomputes → UI updates → SwiftData saves → CloudKit syncs
```

## Layout adaptation

``GameDetailView`` switches on the horizontal size class:

- **Compact (iPhone):** ``CompactScoreHeader`` above two stacked
  ``CompactTeamSection`` views.
- **Regular (iPad):** ``GameInfoCard`` above two side-by-side
  ``CompactTeamSection`` views.

## Sync

The single app-wide `ModelContainer` is configured with
`cloudKitDatabase: .automatic`. Local saves upload to the user's iCloud
container, other signed-in devices download the changes, and each device's
`@Query`/`@Bindable` views update automatically. (CloudKit sync runs on device,
not in the iOS Simulator.)
