//
//  SetupView.swift
//  PushUpCounterDemo
//
//  Created by Filip Ljubicic on 28/01/2026.
//

import SwiftUI

struct SetupView: View {
    let mode: WorkoutMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedValue: Int
    
    // Reps: 5-100 in increments of 5
    private let repsRange = Array(stride(from: 5, through: 100, by: 5))
    
    // Time: 30-300 seconds in increments of 30
    private let timeRange = Array(stride(from: 30, through: 300, by: 30))
    
    private var pickerRange: [Int] {
        mode == .reps ? repsRange : timeRange
    }
    
    private var pickerLabel: String {
        mode == .reps ? "reps" : "seconds"
    }
    
    init(mode: WorkoutMode) {
        self.mode = mode
        if mode == .reps {
            _selectedValue = State(initialValue: 20) // Default 20 reps
        } else {
            _selectedValue = State(initialValue: 60) // Default 60 seconds
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Mode Display
                VStack(spacing: 12) {
                    Image(systemName: mode == .reps ? "number.circle.fill" : "timer")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("\(mode.displayName) Mode")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("Set your target")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Picker
                VStack(spacing: 20) {
                    Picker("Target \(pickerLabel)", selection: $selectedValue) {
                        ForEach(pickerRange, id: \.self) { value in
                            Text("\(value) \(pickerLabel)")
                                .tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 200)
                    
                    Text("Selected: \(selectedValue) \(pickerLabel)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                .padding(.horizontal, 20)
                
                // Instructions
                VStack(spacing: 12) {
                    Image(systemName: "iphone")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Place your phone on the floor")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("with the screen facing you")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Start Button
                NavigationLink(destination: WorkoutView(mode: mode, targetValue: selectedValue)) {
                    Text("Start Workout")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.accentColor)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

