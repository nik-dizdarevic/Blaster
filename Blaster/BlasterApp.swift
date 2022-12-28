//
//  BlasterApp.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

@main
struct BlasterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
