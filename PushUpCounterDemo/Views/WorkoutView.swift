//
//  WorkoutView.swift
//  PushUpCounterDemo
//
//  Created by Filip Ljubicic on 28/01/2026.
//

import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI
import AVFoundation

struct WorkoutView: View {
    let mode: WorkoutMode
    let targetValue: Int
    
    @StateObject private var viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSummary = false
    @State private var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @State private var showPermissionAlert = false
    
    init(mode: WorkoutMode, targetValue: Int) {
        self.mode = mode
        self.targetValue = targetValue
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(mode: mode, targetValue: targetValue, sdkKey: QuickPoseConfig.sdkKey))
    }
    
    var body: some View {
        ZStack {
            // Camera and Overlay
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    QuickPoseCameraView(useFrontCamera: true, delegate: viewModel.getQuickPose())
                    QuickPoseOverlayView(overlayImage: $viewModel.overlayImage)
                }
                .frame(width: geometry.safeAreaInsets.leading + geometry.size.width + geometry.safeAreaInsets.trailing)
                .edgesIgnoringSafeArea(.all)
            }
            
            // Bounding Box Guide (for positioning phase)
            if viewModel.phase == .positioning {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.6), lineWidth: 3)
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.8)
                    .padding()
            }
            
            // Countdown Overlay
            if viewModel.phase == .countdown {
                ZStack {
                    Color.black.opacity(0.7)
                    
                    VStack(spacing: 20) {
                        if viewModel.countdownValue > 0 {
                            Text("\(viewModel.countdownValue)")
                                .font(.system(size: 120, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("GO!")
                                .font(.system(size: 100, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            // Feedback Text Overlay
            if let feedbackText = viewModel.feedbackText, viewModel.phase != .countdown {
                VStack {
                    if viewModel.phase == .positioning {
                        Spacer()
                    }
                    
                    Text(feedbackText)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color.accentColor.opacity(0.85))
                        )
                        .padding(.horizontal, 30)
                        .padding(.bottom, viewModel.phase == .positioning ? 100 : 40)
                    
                    if viewModel.phase != .positioning {
                        Spacer()
                    }
                }
            }
            
            // Active Workout Stats
            if viewModel.phase == .active {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.endWorkout()
                            showSummary = true
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
            
            // Camera Permission Denied View
            if cameraPermissionStatus == .denied || cameraPermissionStatus == .restricted {
                ZStack {
                    Color.black.opacity(0.8)
                    
                    VStack(spacing: 24) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("Camera Access Required")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Please enable camera access in Settings to use the push-up counter.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL)
                            }
                        }) {
                            Text("Open Settings")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        }
                        .padding(.top, 8)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 8)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            checkCameraPermission()
        }
        .onDisappear {
            viewModel.stopQuickPose()
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: cameraPermissionStatus) { newStatus in
            if newStatus == .authorized {
                viewModel.startQuickPose()
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
        .onChange(of: viewModel.phase) { newPhase in
            // Show summary when workout completes automatically
            if newPhase == .completed {
                showSummary = true
            }
        }
        .fullScreenCover(isPresented: $showSummary) {
            SummaryView(
                mode: mode,
                targetValue: targetValue,
                completedReps: viewModel.completedReps,
                duration: viewModel.totalDuration,
                onDismiss: {
                    // Dismiss WorkoutView to return to HomeView
                    dismiss()
                }
            )
        }
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermissionStatus = status
        
        switch status {
        case .notDetermined:
            // Request permission for the first time
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionStatus = granted ? .authorized : .denied
                }
            }
        case .authorized:
            // Permission already granted, start QuickPose
            viewModel.startQuickPose()
            UIApplication.shared.isIdleTimerDisabled = true
        case .denied, .restricted:
            // Permission denied or restricted
            break
        @unknown default:
            break
        }
    }
}


