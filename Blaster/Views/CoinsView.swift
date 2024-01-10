//
//  CoinsView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI
import CoreData

struct CoinsView: View {
    @EnvironmentObject var store: CoinFetcher
    @Environment(\.managedObjectContext) var context
        
    @FetchRequest(fetchRequest: Coin.fetchRequest(NSPredicate(format: "marketCapRank > %i AND marketCapRank <= %i", 0, 100))) private var coins: FetchedResults<Coin>

    @AppStorage("currency") var currency: Currency = .usd
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(coins) { coin in
                    NavigationLink {
                        CoinDetailedView(coin: coin)
                    } label: {
                        CoinSummaryView(coin: coin)
                    }
                }
            }
            .navigationTitle("Market")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    menu
                }
            }
            .refreshable {
                await store.fetchAndStoreCoins(currency: currency, context: context)
            }
        }
        .task {
            await store.fetchAndStoreCoins(currency: currency, context: context)
        }
    }
    
    var menu: some View {
        Menu {
            NavigationLink {
                SettingsView()
            } label: {
                Label("Settings", systemImage: "gearshape")
            }
            NavigationLink {
                AboutView()
            } label: {
                Text("About")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = CoinFetcher(named: "Default")
        CoinsView()
            .environmentObject(store)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
