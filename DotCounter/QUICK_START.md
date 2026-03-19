//
//  QUICK_START.md
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

# 🚀 Quick Start Guide

## Step 1: Add Files to Xcode Project

The files have been created but need to be added to your Xcode project:

1. **In Xcode**, look at the Project Navigator (left sidebar)
2. You should see new files appear automatically, or:
3. **Right-click** on the "DotCounter" group
4. Select **"Add Files to 'DotCounter'..."**
5. Select all the new files:
   - `Models/GameSession.swift`
   - `Models/Team.swift`
   - `Views/GameListView.swift`
   - `Views/CreateGameView.swift`
   - `Views/GameDetailView.swift`
6. Click **"Add"**

## Step 2: Enable iCloud

**REQUIRED for iCloud sync:**

1. Select your **project** in Project Navigator (the blue icon at the top)
2. Select the **"DotCounter" target**
3. Click the **"Signing & Capabilities"** tab
4. Click **"+ Capability"**
5. Double-click **"iCloud"**
6. In the iCloud section, check **☑️ CloudKit**
7. Done! Xcode creates the container automatically.

## Step 3: Build and Run

1. Select your target device (iPhone or iPad simulator)
2. Press **⌘R** or click the ▶️ Play button
3. The app should launch showing "No Games"

## Step 4: Create Your First Game

1. Tap the **"+"** button (top-right)
2. Choose **1v1** or **2v2**
3. Enter player names
4. Tap **"Create"**
5. Tap the game to open it
6. Start scoring by tapping the point buttons!

## Step 5: Test iCloud Sync (Optional)

**Important**: iCloud sync does **NOT** work in the simulator!

To test sync:
1. Connect a **physical iPhone or iPad**
2. Make sure you're **signed into iCloud** on the device
3. Build and run on the device
4. Create a game
5. Wait 10-30 seconds
6. Open the app on another device with the **same Apple ID**
7. The game should appear!

## Common Issues & Solutions

### ❌ "Cannot find 'GameSession' in scope"
**Solution**: Make sure all files are added to the project target
1. Select each new file in Project Navigator
2. Check the **Target Membership** in the right sidebar
3. Ensure "DotCounter" is checked

### ❌ Build errors about deployment target
**Solution**: Update iOS Deployment Target
1. Select project → Target → Build Settings
2. Search for "iOS Deployment Target"
3. Set to **17.0** or higher

### ❌ iCloud not syncing
**Solution**: 
- Verify iCloud capability is enabled
- Make sure you're on a **real device** (not simulator)
- Check you're signed into iCloud
- Wait 30+ seconds for initial sync

### ❌ App crashes on launch
**Solution**:
1. Check the **console** (⌘⇧Y) for error messages
2. Clean build folder (**⌘⇧K**)
3. Rebuild (**⌘B**)
4. Run again

## Features Overview

### Game List Screen
- View all your games
- See current scores
- Status badges (Active/Completed)
- Tap a game to play
- Swipe to delete
- "+" to create new game

### Create Game Screen
- Choose 1v1 or 2v2
- Enter player names
- Validation ensures all names filled
- Cancel or Create

### Game Detail Screen
- Large score display
- Point buttons: +5, +10, +15, +20, +25, +30, +35
- Undo button (per team)
- Score history timeline
- Auto-win at 35+ points
- End Game button

### iPad Layout
- Side-by-side team view
- Optimized for larger screen
- Same functionality as iPhone

## Tips

💡 **Undo is your friend**: Made a mistake? Just tap "Undo Last Score"

💡 **+35 auto-wins**: Reaching 35+ points automatically ends the game

💡 **History tracking**: Every score change is tracked, view the timeline

💡 **iCloud is automatic**: No manual sync needed once enabled

💡 **Works offline**: Games save locally and sync when online

## File Organization (Recommended)

Organize your files in Xcode:

```
DotCounter/
├── 📁 App/
│   └── DotCounterApp.swift
├── 📁 Models/
│   ├── GameSession.swift
│   └── Team.swift
├── 📁 Views/
│   ├── GameListView.swift
│   ├── CreateGameView.swift
│   └── GameDetailView.swift
└── 📁 Resources/
    └── Assets.xcassets
```

To create groups:
1. Right-click in Project Navigator
2. Select "New Group"
3. Name it (Models, Views, etc.)
4. Drag files into groups

## What's Next?

✅ **You're ready to track Domino scores!**

Optional enhancements:
- Add app icon
- Customize colors
- Add sound effects
- Implement game statistics
- Add player profiles

## Need Help?

- Check `PROJECT_SUMMARY.md` for complete feature list
- Check `SETUP_NOTES.md` for troubleshooting
- Check `README.md` for detailed documentation

---

**Enjoy tracking your Domino games! 🎮**
