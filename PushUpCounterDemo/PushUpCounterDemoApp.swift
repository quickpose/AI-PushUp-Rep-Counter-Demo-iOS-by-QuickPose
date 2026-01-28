//
//  PushUpCounterDemoApp.swift
//  PushUpCounterDemo
//
//  Created by Filip Ljubicic on 28/01/2026.
//

import SwiftUI
import CoreData

@main
struct PushUpCounterDemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
