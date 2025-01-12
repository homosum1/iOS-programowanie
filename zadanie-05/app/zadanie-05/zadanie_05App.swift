//
//  zadanie_05App.swift
//  zadanie-05
//
//  Created by Alexander on 09/01/2025.
//

import SwiftUI

@main
struct zadanie_05App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
