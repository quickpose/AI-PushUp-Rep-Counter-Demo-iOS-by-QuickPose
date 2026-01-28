//
//  HomeView.swift
//  PushUpCounterDemo
//
//  Created by Filip Ljubicic on 28/01/2026.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutSession.date, ascending: false)],
        animation: .default)
    private var workouts: FetchedResults<WorkoutSession>
    
    @State private var selectedMode: WorkoutMode?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Push-Up Counter")
                        .font(.system(size: 42, weight: .bold))
                        .padding(.top, 20)
                    
                    Text("Select your workout mode")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 30)
                
                // Mode Selection Buttons
                VStack(spacing: 20) {
                    Button(action: {
                        selectedMode = .reps
                    }) {
                        HStack {
                            Image(systemName: "number.circle.fill")
                                .font(.system(size: 30))
                            Text("Reps Mode")
                                .font(.system(size: 24, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    
                    Button(action: {
                        selectedMode = .time
                    }) {
                        HStack {
                            Image(systemName: "timer")
                                .font(.system(size: 30))
                            Text("Time Mode")
                                .font(.system(size: 24, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.accentColor.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                
                Divider()
                
                // Workout History
                if workouts.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "numbers.rectangle")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No workouts yet")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                        Text("Start your first workout above")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(workouts) { workout in
                            WorkoutRow(workout: workout)
                        }
                        .onDelete(perform: deleteWorkouts)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedMode) { mode in
                SetupView(mode: mode)
            }
        }
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        withAnimation {
            offsets.map { workouts[$0] }.forEach { workout in
                PersistenceController.shared.deleteWorkout(workout)
            }
        }
    }
}

struct WorkoutRow: View {
    let workout: WorkoutSession
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private var durationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.mode?.capitalized ?? "Unknown")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(dateFormatter.string(from: workout.date ?? Date()))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("\(workout.completedReps) reps", systemImage: "number.circle")
                    .font(.system(size: 14))
                Spacer()
                Label(durationFormatter.string(from: workout.duration) ?? "0s", systemImage: "timer")
                    .font(.system(size: 14))
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

extension WorkoutMode: Identifiable {
    public var id: String { rawValue }
}

