//
//  Persistence.swift
//  PushUpCounterDemo
//
//  Created by Filip Ljubicic on 28/01/2026.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<5 {
            let workout = WorkoutSession(context: viewContext)
            workout.id = UUID()
            workout.date = Date().addingTimeInterval(TimeInterval(-i * 86400))
            workout.mode = i % 2 == 0 ? "reps" : "time"
            workout.targetValue = Int32(i % 2 == 0 ? 20 : 60)
            workout.completedReps = Int32(15 + i * 2)
            workout.duration = Double(30 + i * 10)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PushUpCounterDemo")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - WorkoutSession CRUD Operations
    
    func saveWorkout(mode: String, targetValue: Int, completedReps: Int, duration: Double, averageFormScore: Double? = nil) {
        let context = container.viewContext
        let workout = WorkoutSession(context: context)
        workout.id = UUID()
        workout.date = Date()
        workout.mode = mode
        workout.targetValue = Int32(targetValue)
        workout.completedReps = Int32(completedReps)
        workout.duration = duration
        workout.averageFormScore = averageFormScore ?? 0.0
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Error saving workout: \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deleteWorkout(_ workout: WorkoutSession) {
        let context = container.viewContext
        context.delete(workout)
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Error deleting workout: \(nsError), \(nsError.userInfo)")
        }
    }
}
