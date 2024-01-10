//
//  WatchlistView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

struct WatchlistView: View {
    
    @EnvironmentObject var store: CoinFetcher
    @Environment(\.managedObjectContext) var context
    
    @State private var search = false
    
    @AppStorage("currency") var currency: Currency = .usd
    
    @FetchRequest(fetchRequest: Coin.fetchRequest(NSPredicate(format: "watchList == true"))) private var coins: FetchedResults<Coin>
    
    var body: some View {
        NavigationStack {
            Group {
                if coins.isEmpty {
                    nothing
                } else {
                    List {
                        ForEach(coins) { coin in
                            NavigationLink {
                                CoinDetailedView(coin: coin)
                            } label: {
                                CoinSummaryView(coin: coin)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet.sorted(by: >) {
                                coins[index].watchListToggle()
                            }
                        }
                    }
                    .refreshable {
                        await store.fetchAndStoreCoins(with: ids, currency: currency, context: context)
                    }
                }
            }
            .navigationTitle("Watchlist")
            .toolbar {
                if !coins.isEmpty {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        HStack {
                            EditButton()
                            plusButton
                        }
                        
                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        plusButton
                    }
                }
            }
            .sheet(isPresented: $search) {
                SearchView(type: .watchlist)
            }
        }
        .task {
            await store.fetchAndStoreCoins(with: ids, currency: currency, context: context)
        }
    }
    
    var ids: [String] {
        coins.map { $0.id }
    }
    
    var plusButton: some View {
        PlusButton {
            search = true
        }
    }
    
    var nothing: some View {
        VStack {
            Image(systemName: "star.fill")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.gray)
            Text("Nothing Here")
                .font(.title2.weight(.bold))
            Spacer()
                .frame(height: DrawingConstants.frameHeight)
            Text("Add a new coin to get started.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private struct DrawingConstants {
        static let frameHeight: CGFloat = 3
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}
