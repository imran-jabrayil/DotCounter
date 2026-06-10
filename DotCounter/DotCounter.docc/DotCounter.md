# ``DotCounter``

A native SwiftUI app for tracking scores in domino games, with iCloud sync.

## Overview

DotCounter records scores for 1v1 and 2v2 domino matches. Each game has two
teams; you add points with quick-add buttons and the running score history is
kept per team so any entry can be undone.

The **+35 button is an intentional "capot" instant win** — pressing it ends the
game for that team. Adding up to or past 35 with the smaller buttons does *not*
auto-win; a match can also be ended manually at any time. An accidental instant
win can be reopened from the game screen.

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

### Components

- ``GameRowView``
- ``GameInfoCard``
- ``CompactScoreHeader``
- ``CompactTeamSection``
- ``StatusBadge``
