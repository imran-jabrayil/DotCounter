# DotCounter - Domino Score Tracker

A native iOS app built with SwiftUI for tracking scores in Domino games with support for 1v1 and 2v2 matches.

## Features

### ✅ Implemented Features

1. **Game Session Creation**
   - Support for 1v1 and 2v2 game modes
   - Custom player names for each team
   - Segmented picker for easy mode selection

2. **Native iOS Design**
   - Built entirely with native SwiftUI components
   - Responsive design for iPhone and iPad
   - Adaptive layouts using horizontal size classes
   - System colors and materials
   - Native navigation and sheets

3. **Game Management**
   - List view of all games (active and completed)
   - Game status badges (Active/Completed)
   - End game functionality with confirmation
   - Delete games with swipe actions
   - Empty state with call-to-action

4. **Scoring System**
   - Quick-add buttons for: +5, +10, +15, +20, +25, +30, +35
   - The +35 button is an instant "capot" win: it ends the game for the team
     that pressed it. Smaller increments add points without auto-ending the game.
   - Visual feedback for winning team
   - Green highlight for the +35 (instant-win) button
   - Real-time score updates
   - An accidental instant win can be undone from the game screen

5. **Score History & Undo**
   - Complete score history tracking from 0 to current
   - Independent undo functionality per team
   - Visual score history timeline
   - Unlimited undo back to the start (0 points)
   - Shows score differences between rounds

6. **iCloud Synchronization**
   - SwiftData with CloudKit integration
   - Automatic sync across devices
   - Conflict resolution handled by CloudKit

7. **iPad Support**
   - Side-by-side team layout on iPad
   - Optimized use of screen real estate
   - Horizontal size class detection

## Architecture

### Models (SwiftData)
- **GameSession**: Represents a complete game with teams, status, and metadata
- **Team**: Contains players, score history, and scoring logic
- **GameMode**: Enum for 1v1 or 2v2
- **GameStatus**: Enum for Active or Completed

### Views
- **GameListView**: Main screen showing all games
- **CreateGameView**: Modal sheet for creating new games
- **GameDetailView**: Active game screen with scoring interface
- **Supporting Views**: GameRowView, GameInfoCard, TeamScoringCard, StatusBadge

## Setup Instructions

### 1. Enable iCloud Capability

To enable iCloud synchronization, you need to add the iCloud capability to your Xcode project:

1. Select your project in the Project Navigator
2. Select your app target
3. Go to the "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "iCloud"
6. Check "CloudKit"
7. Xcode will automatically create a CloudKit container for you

### 2. Build and Run

1. Open the project in Xcode
2. Select your target device or simulator
3. Build and run (⌘R)

### 3. Testing iCloud Sync

To test iCloud synchronization:

1. Sign in with the same Apple ID on multiple devices
2. Create a game on one device
3. Wait a few seconds for sync
4. Open the app on another device to see the synced game

**Note**: iCloud sync does not work in the iOS Simulator. You must test on physical devices.

## Usage Guide

### Creating a Game

1. Tap the "+" button in the top-right corner
2. Select game mode (1v1 or 2v2)
3. Enter player names for both teams
4. Tap "Create"

### Scoring

1. Select a game from the list
2. Tap the point buttons (+5, +10, etc.) to add scores
3. The current score updates immediately
4. Tap +35 to record an instant "capot" win — the game ends and that team wins.
   If pressed by mistake, tap "Undo" in the toolbar to reopen the game.

### Undoing Scores

1. Tap the "Undo Last Score" button for the respective team
2. You can undo multiple times back to the start (0 points)
3. The undo button is disabled when at the initial state

### Ending a Game

1. Tap "End Game" in the top-right corner
2. Confirm the action
3. The game status changes to "Completed"

### Deleting a Game

1. In the game list, swipe left on a game
2. Tap "Delete"
- OR -
1. Tap "Edit" in the top-left corner
2. Select games to delete
3. Tap "Delete"

## Technical Details

### SwiftData & CloudKit

The app uses SwiftData (Apple's modern persistence framework) with automatic CloudKit synchronization. The `ModelConfiguration` is set up with:

```swift
ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .automatic
)
```

This enables:
- Automatic sync to iCloud
- Data persistence on device
- Conflict resolution
- Multi-device support

### iPad Optimization

The app detects the horizontal size class to provide optimal layouts:

- **iPhone (compact)**: Vertical stack layout with scrolling
- **iPad (regular)**: Side-by-side team comparison view

### Performance Considerations

- SwiftData uses efficient queries with `@Query` property wrapper
- Score history is stored as an array for O(1) append operations
- Undo is O(1) using array `removeLast()`

## Future Enhancements (Optional)

- [ ] Game statistics and analytics
- [ ] Export game results
- [ ] Customizable winning score
- [ ] Dark mode optimizations
- [ ] Accessibility improvements (VoiceOver labels)
- [ ] Localization support
- [ ] Game templates
- [ ] Player profiles

## Requirements

- iOS 17.0+
- iPadOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## License

Copyright © 2026 Imran Jabrayilov. All rights reserved.
