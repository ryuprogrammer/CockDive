//
//  CockDiveApp.swift
//  CockDive
//
//  Created by トム・クルーズ on 2024/05/09.
//

import SwiftUI

@main
struct CockDiveApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
