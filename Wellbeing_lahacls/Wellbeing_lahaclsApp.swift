//
//  Wellbeing_lahaclsApp.swift
//  Wellbeing_lahacls
//
//  Created by Oscar Henry Cooper Stern on 4/26/25.
//

import SwiftUI

@main
struct Wellbeing_lahaclsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
