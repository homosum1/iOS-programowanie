//
//  zadanie_06App.swift
//  zadanie-06
//
//  Created by Alexander on 12/01/2025.
//

import SwiftUI

@main
struct zadanie_06App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
