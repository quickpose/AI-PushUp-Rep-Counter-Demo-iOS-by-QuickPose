//
//  SummaryView.swift
//  PushUpCounterDemo
//
//  Created by Filip Ljubicic on 28/01/2026.
//

import SwiftUI

struct SummaryView: View {
    let mode: WorkoutMode
    let targetValue: Int
    let completedReps: Int
    let duration: TimeInterval
    var onDismiss: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isSaved = false
    
    private var durationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }
    
    private var averageTimePerRep: TimeInterval {
        guard completedReps > 0 else { return 0 }
        return duration / Double(completedReps)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Workout Complete!")
                        .font(.system(size: 36, weight: .bold))
                }
                .padding(.top, 40)
                
                // Stats Card
                VStack(spacing: 20) {
                    StatRow(
                        icon: "number.circle.fill",
                        label: "Reps Completed",
                        value: "\(completedReps)"
                    )
                    
                    Divider()
                    
                    StatRow(
                        icon: "timer",
                        label: "Duration",
                        value: durationFormatter.string(from: duration) ?? "0s"
                    )
                    
                    if completedReps > 0 {
                        Divider()
                        
                        StatRow(
                            icon: "clock.fill",
                            label: "Average Time per Rep",
                            value: String(format: "%.1f sec", averageTimePerRep)
                        )
                    }
                    
                    Divider()
                    
                    StatRow(
                        icon: mode == .reps ? "target" : "hourglass",
                        label: "Mode & Target",
                        value: "\(mode.displayName) - \(targetValue) \(mode == .reps ? "reps" : "sec")"
                    )
                }
                .padding(24)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        saveWorkout()
                    }) {
                        Text(isSaved ? "Saved!" : "Save & Continue")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(isSaved ? Color.green : Color.accentColor)
                            .cornerRadius(16)
                    }
                    .disabled(isSaved)
                    
                    Button(action: {
                        dismiss()
                        // Also dismiss the parent WorkoutView to return to HomeView
                        onDismiss?()
                    }) {
                        Text("Discard")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveWorkout() {
        PersistenceController.shared.saveWorkout(
            mode: mode.rawValue,
            targetValue: targetValue,
            completedReps: completedReps,
            duration: duration
        )
        isSaved = true
        
        // Auto-dismiss after a short delay to show "Saved!" confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
            // Also dismiss the parent WorkoutView to return to HomeView
            onDismiss?()
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
                .frame(width: 40)
            
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .semibold))
        }
    }
}

