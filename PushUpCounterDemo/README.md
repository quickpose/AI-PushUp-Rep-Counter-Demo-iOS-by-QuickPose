# Push-Up Counter Demo

A demo app showcasing the QuickPose SDK for counting push-up reps using AI pose estimation.

## Setup Instructions

### 1. QuickPose SDK Key

1. Register for a free SDK key at [https://dev.quickpose.ai](https://dev.quickpose.ai)
2. Open `QuickPoseConfig.swift`
3. Replace `YOUR_SDK_KEY_HERE` with your actual SDK key

**Important:** SDK Keys are linked to your bundle ID (`ai.quickpose.PushUpCounterDemo`). Make sure to check your key before distributing to the App Store.

### 2. Camera Permissions

Since this project uses `GENERATE_INFOPLIST_FILE = YES`, you need to add the camera permission in Xcode:

1. Open the project in Xcode
2. Select the project in the navigator
3. Select the "PushUpCounterDemo" target
4. Go to the "Info" tab
5. Click the "+" button to add a new key
6. Add: `Privacy - Camera Usage Description`
7. Set the value to: `Camera is required to track your push-up form and count reps`

Alternatively, you can add this directly to the build settings:
- In Build Settings, search for "Info.plist"
- Add `INFOPLIST_KEY_NSCameraUsageDescription` with the value above

## Features

- **Reps Mode**: Count push-ups until you reach your target
- **Time Mode**: Count as many push-ups as possible within a time limit
- **Real-time Pose Detection**: Uses QuickPose SDK for accurate rep counting
- **Workout History**: View and manage past workout sessions
- **Form Feedback**: Get guidance on proper push-up form

## Usage

1. Launch the app
2. Select "Reps Mode" or "Time Mode"
3. Set your target using the picker
4. Place your phone on the floor with the screen facing you
5. Get into position within the bounding box
6. Wait for the 3-second countdown
7. Start doing push-ups!
8. View your results and save to history

## Requirements

- iOS 26.2+
- Xcode 26.2+
- QuickPose SDK (already integrated via Swift Package Manager)
