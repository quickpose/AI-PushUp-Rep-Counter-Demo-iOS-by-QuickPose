//
//  WorkoutViewModel.swift
//  PushUpCounterDemo
//
//  Created by Filip Ljubicic on 28/01/2026.
//

import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI
import Combine

enum WorkoutPhase {
    case positioning
    case countdown
    case active
    case completed
}

@MainActor
class WorkoutViewModel: ObservableObject {
    // QuickPose
    private var quickPose: QuickPose
    @Published var overlayImage: UIImage?
    private var isQuickPoseStopped = false
    
    // Workout State
    @Published var phase: WorkoutPhase = .positioning
    @Published var countdownValue: Int = 3
    @Published var repCount: Int = 0
    @Published var workoutDuration: TimeInterval = 0
    @Published var remainingTime: TimeInterval = 0
    @Published var feedbackText: String?
    @Published var isPositioned: Bool = false
    
    // Configuration
    let mode: WorkoutMode
    let targetValue: Int
    private var counter: QuickPoseThresholdCounter
    private var positionStableTimer: Timer?
    private var workoutTimer: Timer?
    private var countdownTimer: Timer?
    
    // Results
    var completedReps: Int { repCount }
    var totalDuration: TimeInterval { workoutDuration }
    
    init(mode: WorkoutMode, targetValue: Int, sdkKey: String) {
        self.mode = mode
        self.targetValue = targetValue
        self.quickPose = QuickPose(sdkKey: sdkKey)
        self.counter = QuickPoseThresholdCounter()
        
        if mode == .time {
            self.remainingTime = TimeInterval(targetValue)
        }
    }
    
    func startQuickPose() {
        isQuickPoseStopped = false
        quickPose.start(features: [.overlay(.upperBody), .fitness(.pushUps)], onFrame: { [weak self] status, image, features, feedback, landmarks in
            guard let self = self else { return }
            
            Task { @MainActor in
                switch status {
                case .success:
                    self.overlayImage = image
                    
                    if let result = features.values.first {
                        // Update rep count (only during active workout)
                        if self.phase == .active {
                            let counterState = self.counter.count(result.value)
                            self.repCount = counterState.count
                            
                            // Check if target reps reached (check here for immediate response)
                            if self.mode == .reps && self.repCount >= self.targetValue {
                                self.endWorkout()
                                return
                            }
                            
                            // Show rep count during active workout
                            if self.mode == .reps {
                                self.feedbackText = "\(self.repCount) / \(self.targetValue) reps"
                            } else {
                                let minutes = Int(self.remainingTime) / 60
                                let seconds = Int(self.remainingTime) % 60
                                self.feedbackText = "\(self.repCount) reps\n\(String(format: "%02d:%02d", minutes, seconds))"
                            }
                        } else if self.phase == .positioning {
                            // During positioning, check if we have a valid result and no required feedback
                            // This means user is properly positioned
                            if result.value >= 0 && feedback.values.isEmpty {
                                if !self.isPositioned {
                                    self.isPositioned = true
                                    self.startPositionStableTimer()
                                }
                            }
                        }
                    }
                    
                    // Handle feedback messages
                    if let feedbackItem = feedback.values.first, feedbackItem.isRequired {
                        // Show form feedback
                        self.feedbackText = feedbackItem.displayString
                        if self.phase == .positioning {
                            self.isPositioned = false
                            self.positionStableTimer?.invalidate()
                        }
                    } else if self.phase == .positioning && self.feedbackText == nil {
                        // Default positioning message
                        self.feedbackText = "Get into position"
                    }
                    
                case .noPersonFound:
                    self.overlayImage = nil
                    if self.phase == .positioning {
                        self.feedbackText = "Stand in view"
                        self.isPositioned = false
                        self.positionStableTimer?.invalidate()
                    }
                    
                case .sdkValidationError:
                    self.feedbackText = "SDK Error - Please check your configuration"
                }
            }
        })
    }
    
    func stopQuickPose() {
        guard !isQuickPoseStopped else { return }
        isQuickPoseStopped = true
        quickPose.stop()
        positionStableTimer?.invalidate()
        workoutTimer?.invalidate()
        countdownTimer?.invalidate()
    }
    
    func getQuickPose() -> QuickPose {
        return quickPose
    }
    
    private func startPositionStableTimer() {
        positionStableTimer?.invalidate()
        positionStableTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, self.isPositioned else { return }
                self.startCountdown()
            }
        }
    }
    
    private func startCountdown() {
        phase = .countdown
        countdownValue = 3
        feedbackText = nil
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                self.countdownValue -= 1
                
                if self.countdownValue <= 0 {
                    timer.invalidate()
                    self.startWorkout()
                }
            }
        }
    }
    
    private func startWorkout() {
        phase = .active
        repCount = 0
        workoutDuration = 0
        counter = QuickPoseThresholdCounter() // Reset counter
        
        // Start workout timer
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                self.workoutDuration += 0.1
                
                // Handle time mode countdown
                if self.mode == .time {
                    self.remainingTime -= 0.1
                    if self.remainingTime <= 0 {
                        self.endWorkout()
                    }
                } else if self.mode == .reps {
                    // Check if target reps reached
                    if self.repCount >= self.targetValue {
                        self.endWorkout()
                    }
                }
            }
        }
    }
    
    func endWorkout() {
        workoutTimer?.invalidate()
        countdownTimer?.invalidate()
        phase = .completed
        stopQuickPose()
    }
    
    deinit {
        // Direct cleanup in deinit - timers can be invalidated from any thread
        positionStableTimer?.invalidate()
        workoutTimer?.invalidate()
        countdownTimer?.invalidate()
        
        // For QuickPose cleanup, use MainActor.assumeIsolated since this class is @MainActor
        // and we're in the deinit of a main actor-isolated class
        MainActor.assumeIsolated {
            quickPose.stop()
        }
    }
}
