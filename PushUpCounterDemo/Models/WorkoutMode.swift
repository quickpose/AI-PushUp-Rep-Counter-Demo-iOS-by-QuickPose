//
//  WorkoutMode.swift
//  PushUpCounterDemo
//
//  Created by Filip Ljubicic on 28/01/2026.
//

import Foundation

enum WorkoutMode: String, CaseIterable {
    case reps
    case time
    
    var displayName: String {
        switch self {
        case .reps:
            return "Reps"
        case .time:
            return "Time"
        }
    }
}
