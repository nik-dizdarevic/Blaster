//
//  BlasterApp.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

@main
struct BlasterApp: App {
    
    @StateObject var store = CoinFetcher(named: "Default")
    let persistenceController = PersistenceController.shared
    
    @AppStorage("startPage") var startPage: Page = .market

    var body: some Scene {
        WindowGroup {
            HomeView(startPage: startPage)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(store)
        }
    }
}
