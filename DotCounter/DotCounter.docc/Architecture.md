# Architecture

How DotCounter is structured: navigation, data model, rules, and the scoring flow.

## Overview

DotCounter is a small, idiomatic SwiftData + SwiftUI app. There is no view-model
layer — views observe the model directly through `@Query` and `@Bindable`, and
all game rules live on the model types (``GameSession`` and ``Team``).

## Source layout

```
DotCounter/
├── App/          DotCounterApp (entry point + ModelContainer), AppStorageKeys
├── Models/       GameSession, Team, GameMode, GameStatus
├── Views/
│   ├── GameList/    GameListView, GameRowView
│   ├── GameDetail/  GameDetailView, GameInfoCard, CompactScoreHeader, CompactTeamSection
│   ├── CreateGame/  CreateGameView
│   ├── Onboarding/  OnboardingView
│   └── Settings/    SettingsView
├── Components/   StatusBadge, ConfettiView (shared)
└── DotCounter.docc/  this documentation catalog
```

## Navigation flow

```
DotCounterApp (ModelContainer + CloudKit)
        │
        ▼
GameListView (NavigationSplitView) ──[+]──▶ CreateGameView (sheet)
        │                          ──[⚙]──▶ SettingsView (sheet)
        │                          ──first launch──▶ OnboardingView (fullScreenCover)
        │
        └──[select game]──▶ GameDetailView (scoring screen, detail column on iPad)
```

- ``GameListView`` lists every ``GameSession`` newest-first via `@Query`, using a
  `NavigationSplitView` so iPad shows list + detail side-by-side and iPhone
  collapses to a pushed stack.
- ``OnboardingView`` is shown on first launch (gated on `hasCompletedOnboarding`)
  to capture the default house rules.
- ``SettingsView`` edits those global default rules later.
- ``CreateGameView`` snapshots the current default rules onto a new game and
  inserts it into the `modelContext`.
- ``GameDetailView`` edits a `@Bindable` game; changes auto-save and sync.

## Data model

```
GameSession
 ├─ id, createdAt, gameMode, status, winningTeam?, wonByInstantWin
 ├─ targetScore, capotInstantWin, autoEndAtTarget   // per-game rule snapshot
 ├─ team1: Team   (cascade delete)
 └─ team2: Team   (cascade delete)

Team
 ├─ player1Name, player2Name?
 └─ scoreHistory: [Int]   // cumulative, starts at [0]
```

Relationships are optional and every property has a default value, as required
for CloudKit-backed SwiftData models. The three rule properties have defaults,
so adding them is a lightweight migration. A team's ``Team/currentScore`` is the
last entry of ``Team/scoreHistory``, which makes undo a simple `removeLast`.

## Rules & their scope

Two house rules are configurable:

- **``GameSession/capotInstantWin``** — whether a single +35
  (``GameSession/capotValue``) move wins outright.
- **``GameSession/autoEndAtTarget``** — whether reaching
  ``GameSession/targetScore`` (365 by default) ends the game automatically, vs.
  finishing the round and ending manually.

The user sets *global defaults* in onboarding/settings (stored in `UserDefaults`
via `@AppStorage`, keys centralised in `AppStorageKeys`). Each ``GameSession``
**snapshots** the rules at creation, so changing the defaults later never alters
a game already in progress.

## Scoring & win flow

```
User taps +N on a team
        │
        ▼
GameDetailView.addScore(N, side)
        │
        ▼
game.applyScore(points: N, toTeam: side)   // all rules live here
        │
        ├─ +35 and capotInstantWin?  → recordInstantWin(side)  → .capotWin
        ├─ autoEndAtTarget and total ≥ targetScore? → recordTargetWin(side) → .targetWin
        └─ otherwise                 → .scored (SwiftData auto-saves, CloudKit syncs)
        │
        ▼
GameDetailView reacts to the ScoreOutcome:
  .scored → light haptic
  .capotWin / .targetWin → success haptic + "Winner!" alert + confetti
```

A win records the team that triggered it — it is deliberately not re-derived
from the scores, so an opponent already at the target cannot steal a capot win.
A completed **capot** win reports ``GameSession/canReopen`` and can be undone
with ``GameSession/reopen()`` (which removes the +35 entry and reactivates the
game); target wins and manual ends are not reopenable.

Ending a game manually via the toolbar calls ``GameSession/endGame()``, which
declares a winner only if a team has already reached ``GameSession/targetScore``
(otherwise the game ends with no winner). This is the path used to finish the
round when ``GameSession/autoEndAtTarget`` is disabled.

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
  ``CompactTeamSection`` views, shown in the split view's detail column.

## Sync

The single app-wide `ModelContainer` is configured with
`cloudKitDatabase: .automatic`. Local saves upload to the user's iCloud
container, other signed-in devices download the changes, and each device's
`@Query`/`@Bindable` views update automatically. (CloudKit sync runs on device,
not in the iOS Simulator.) Rule *defaults* live in `UserDefaults` and are
per-device.
