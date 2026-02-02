# Push-Up Counter Demo

![Push-Up Counter Demo in action](/gifs/Pushup_Example.gif)

<div align="center">

A demo iOS app showcasing the **QuickPose SDK** for AI-powered push-up counting using real-time pose estimation.

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-18.0+-blue.svg)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-26.2+-blue.svg)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

## 📱 Overview

Push-Up Counter Demo is a complete iOS application that demonstrates how to integrate the QuickPose SDK to build a fitness tracking app. The app uses AI-powered pose estimation to accurately count push-up repetitions in real-time, providing users with visual feedback and workout history tracking.

## ✨ Features

### 🎯 Workout Modes
- **Reps Mode**: Complete a target number of push-ups
- **Time Mode**: Do as many push-ups as possible within a time limit

### 🤖 AI-Powered Tracking
- Real-time pose detection using QuickPose SDK
- Upper-body skeleton overlay for visual feedback
- Automatic rep counting with form validation
- Position detection with bounding box guide

### 📊 Workout Management
- Workout history with Core Data persistence
- Detailed workout summaries (reps, duration, average time per rep)
- Swipe-to-delete workout history

### 🎨 User Experience
- 3-second countdown before workout starts
- Real-time rep counter and timer display
- Form feedback and positioning guidance
- Smooth navigation between screens

## 🚀 Getting Started

### Prerequisites

- **iOS 18.0+**
- **Xcode 26.2+**
- **QuickPose SDK Key** (free at [dev.quickpose.ai](https://dev.quickpose.ai))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/quickpose/AI-PushUp-Rep-Counter-Demo-iOS-by-QuickPose
   cd PushUpCounterDemo
   ```

2. **Open in Xcode**
   ```bash
   open PushUpCounterDemo.xcodeproj
   ```

3. **Configure QuickPose SDK Key**
   - Register for a free SDK key at [https://dev.quickpose.ai](https://dev.quickpose.ai)
   - Open `PushUpCounterDemo/Config/QuickPoseConfig.swift`
   - Replace `YOUR_SDK_KEY_HERE` with your actual SDK key:
   ```swift
   static let sdkKey = "your-actual-sdk-key-here"
   ```

   > **Important:** SDK Keys are linked to your bundle ID (`ai.quickpose.PushUpCounterDemo`). Make sure to check your key before distributing to the App Store.

4. **Camera Permissions**
   
   The camera permission is already configured in the project. If you need to verify:
   - The `NSCameraUsageDescription` is set in the build settings
   - Value: `"Camera is required to track your push-up form and count reps"`

5. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

## 📖 Usage

### Starting a Workout

1. **Launch the app** - You'll see the home screen with mode selection
2. **Choose a mode** - Tap "Reps Mode" or "Time Mode"
3. **Set your target** - Use the picker to select:
   - Reps: 5-100 (increments of 5)
   - Time: 30-300 seconds (increments of 30)
4. **Position your phone** - Place it on the floor with the screen facing you
5. **Get into position** - Align yourself within the bounding box on screen
6. **Wait for countdown** - A 3-second countdown will begin automatically
7. **Start your workout** - Begin doing push-ups!
8. **View results** - After completing (or ending early), see your summary
9. **Save to history** - Tap "Save & Continue" to add to your workout history

### Viewing Workout History

- All past workouts are displayed on the home screen
- Each workout shows:
  - Date and time
  - Mode (Reps/Time)
  - Completed reps
  - Duration
- Swipe left on any workout to delete it

## 🏗️ Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture:

```
PushUpCounterDemo/
├── Views/
│   ├── HomeView.swift          # Main screen with mode selection & history
│   ├── SetupView.swift         # Workout configuration screen
│   ├── WorkoutView.swift       # Active workout with camera
│   └── SummaryView.swift       # Post-workout results
├── ViewModels/
│   └── WorkoutViewModel.swift  # Workout state & QuickPose integration
├── Models/
│   ├── WorkoutMode.swift       # Enum for workout modes
│   └── WorkoutSession          # Core Data entity
├── Services/
│   └── Persistence.swift       # Core Data management
└── Config/
    └── QuickPoseConfig.swift   # SDK key configuration
```

### Key Components

- **QuickPose Integration**: Real-time pose detection and rep counting
- **Core Data**: Persistent storage for workout history
- **SwiftUI**: Modern declarative UI framework
- **AVFoundation**: Camera access and permissions

## 🔧 Configuration

### QuickPose SDK

The app uses the following QuickPose features:
- `.overlay(.upperBody)` - Upper-body skeleton visualization
- `.fitness(.pushUps)` - Push-up detection and counting
- `QuickPoseThresholdCounter` - Rep counting logic

### Core Data Model

The `WorkoutSession` entity stores:
- `id`: UUID
- `date`: Workout timestamp
- `mode`: "reps" or "time"
- `targetValue`: Target reps or seconds
- `completedReps`: Actual reps completed
- `duration`: Workout duration in seconds
- `averageFormScore`: Optional form quality metric

## 📸 Screenshots

> To be added

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

See QuickPose SDK licence (https://github.com/quickpose/quickpose-ios-sdk)

## 🙏 Acknowledgments

- [QuickPose SDK](https://quickpose.ai) - AI-powered pose estimation
- [QuickPose Documentation](https://docs.quickpose.ai) - Comprehensive SDK documentation

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

<div align="center">
Made with ❤️ using SwiftUI and QuickPose SDK
</div>
