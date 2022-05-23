//
//  FoodAIApp.swift
//  FoodAI
//
//  Created by Otourou Da Costa on 23/05/2022.
//

import SwiftUI

@main
struct FoodAIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
