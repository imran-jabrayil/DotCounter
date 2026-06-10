# ``DotCounter``

A native SwiftUI app for tracking scores in domino games, with iCloud sync.

## Overview

DotCounter records scores for 1v1 and 2v2 domino matches. Each game has two
teams; you add points with quick-add buttons and the running score history is
kept per team so any entry can be undone.

The first team to **365 points wins**. Two house rules are configurable on first
launch (and later in Settings):

- **Instant capot win** — a single **+35** move wins outright. When disabled,
  +35 is a normal move that still counts toward 365.
- **Auto-end at 365** — the game ends the moment a team reaches the target. When
  disabled, play continues until the game is ended manually, which then declares
  whoever reached 365.

Each game **snapshots** the rules in force when it was created, so changing the
defaults never affects games already in progress. An accidental capot win can be
reopened from the game screen.

Data is persisted with **SwiftData** and synced across a user's devices via
**CloudKit** (`cloudKitDatabase: .automatic`). The UI updates reactively through
`@Query` and `@Bindable`, with no separate view-model layer.

See <doc:Architecture> for how the pieces fit together.

## Topics

### Getting Started

- <doc:Architecture>

### Models

- ``GameSession``
- ``Team``
- ``GameMode``
- ``GameStatus``

### Screens

- ``GameListView``
- ``CreateGameView``
- ``GameDetailView``
- ``OnboardingView``
- ``SettingsView``

### Components

- ``GameRowView``
- ``GameInfoCard``
- ``CompactScoreHeader``
- ``CompactTeamSection``
- ``StatusBadge``
- ``ConfettiView``
