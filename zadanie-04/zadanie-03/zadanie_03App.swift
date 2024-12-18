//
//  zadanie_03App.swift
//  zadanie-03
//
//  Created by Alexander on 28/11/2024.
//

import SwiftUI

@main
struct zadanie_03App: App {
    let persistenceController = PersistenceController.shared
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(persistenceController)
        }
    }
}
