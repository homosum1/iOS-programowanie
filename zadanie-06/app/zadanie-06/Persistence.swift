//
//  Persistence.swift
//  zadanie-06
//
//  Created by Alexander on 12/01/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "zadanie_06")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
