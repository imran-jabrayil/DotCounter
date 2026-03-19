//
//  SETUP_NOTES.md
//  DotCounter
//
//  Created by Imran Jabrayilov on 01.03.26.
//

# Project Setup Notes

## Files Created

### Models
- `Models/GameSession.swift` - Main game session model with SwiftData
- `Models/Team.swift` - Team model with score history and player management

### Views
- `Views/GameListView.swift` - Main list of all games
- `Views/CreateGameView.swift` - Form for creating new games
- `Views/GameDetailView.swift` - Active game scoring interface

### App Files
- `DotCounterApp.swift` - Updated with SwiftData and CloudKit configuration
- `ContentView.swift` - Original template (no longer used)

## Important: Xcode Project Configuration

### 1. Add Files to Your Project

Since I created these files programmatically, you need to add them to your Xcode project:

**Option A: Using Xcode**
1. In Xcode, right-click on your project navigator
2. Select "Add Files to DotCounter..."
3. Navigate to and select all the new files
4. Make sure "Copy items if needed" is checked
5. Ensure your target is selected

**Option B: Restart Xcode**
Sometimes Xcode will automatically detect the new files after restarting.

### 2. Organize File Structure (Recommended)

Create groups in Xcode to organize your files:

```
DotCounter/
├── App/
│   ├── DotCounterApp.swift
│   └── ContentView.swift (optional - can be deleted)
├── Models/
│   ├── GameSession.swift
│   └── Team.swift
└── Views/
    ├── GameListView.swift
    ├── CreateGameView.swift
    └── GameDetailView.swift
```

### 3. Enable iCloud Capability

**CRITICAL: This step is required for iCloud sync to work**

1. Select your project in the Project Navigator
2. Select the "DotCounter" target
3. Click the "Signing & Capabilities" tab
4. Click "+ Capability" button
5. Double-click "iCloud"
6. In the iCloud section that appears:
   - Check ☑️ "CloudKit"
   - Xcode will create a default container: `iCloud.$(CFBundleIdentifier)`
7. This is all you need! SwiftData will handle the rest.

### 4. Build Settings Check

Ensure your deployment target supports SwiftData:
- iOS Deployment Target: 17.0 or later
- iPadOS Deployment Target: 17.0 or later

To check/update:
1. Select your project
2. Select your target
3. Go to "Build Settings"
4. Search for "iOS Deployment Target"
5. Set to 17.0 or higher

### 5. Testing on Device

**Important**: iCloud sync does NOT work in the iOS Simulator!

To test iCloud functionality:
1. Connect a physical iPhone or iPad
2. Make sure you're signed into iCloud on the device
3. Build and run on the device
4. Test on multiple devices with the same Apple ID to verify sync

### 6. Privacy Manifest (Future Requirement)

If you plan to submit to the App Store, you may need to add a privacy manifest. For now, this isn't required for basic testing.

## Troubleshooting

### "Cannot find type 'GameSession' in scope"
- Make sure all files are added to your Xcode project target
- Check that all files have the correct target membership
- Clean build folder (Shift + Cmd + K) and rebuild

### "iCloud sync not working"
- Verify iCloud capability is enabled
- Check you're signed into iCloud on your device
- iCloud sync doesn't work in Simulator - use real device
- Allow a few seconds for data to sync

### "Build errors about SwiftData"
- Ensure your iOS Deployment Target is 17.0+
- Make sure you're using Xcode 15 or later
- SwiftData is only available on iOS 17+

### "App crashes on launch"
- Check the console for error messages
- Verify all model classes are properly defined
- Ensure ModelContainer configuration is correct

## CloudKit Dashboard (Optional)

To view your CloudKit data:
1. Go to https://icloud.developer.apple.com
2. Sign in with your Apple Developer account
3. Select your container
4. You can view record types, records, and debug sync issues

## Next Steps

1. ✅ Add files to Xcode project
2. ✅ Enable iCloud capability
3. ✅ Build and run
4. ✅ Test on physical device for iCloud sync
5. 🎮 Start tracking your Domino games!

## Questions?

Common questions answered in README.md
