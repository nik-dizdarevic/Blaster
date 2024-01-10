//
//  CoinFetcher.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI
import CoreData

@MainActor
class CoinFetcher: ObservableObject {
    let name: String

    init(named name: String) {
        self.name = name
    }

    private var searchTimer: Timer?

    // MARK: - Intent(s)
    
    // let thisfunction = "\(String(describing: self)).\(#function)"
    func fetchAndStoreCoins(with ids: [String] = [], currency: Currency, context: NSManagedObjectContext) async {
        if let url = Endpoint.coins(with: ids, currency: currency).url {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw ApiError.invalidServerResponse
                }
                let coins = try JSONDecoder().decode([CoingeckoCoin].self, from: data)
                for coin in coins {
                    try resetMarketCapOfDouble(coin: coin, context: context)
                    let updatedCoin = Coin.update(from: coin, in: context)
                    await updatedCoin.fetchThumbnail()
                    if ids.count == 1 {
                        await updatedCoin.fetchChart(range: .one, currency: currency)
                    }
                    updatedCoin.objectWillChange.send()
                }
                try context.save()
                print("saved to database")
            } catch ApiError.invalidServerResponse {
                print("couldn't fetch and save coins: server error")
            } catch {
                print("couldn't fetch and save coins: \(error)")
            }
        } else {
            print("bad url")
        }
    }
    
    private func resetMarketCapOfDouble(coin: CoingeckoCoin, context: NSManagedObjectContext) throws {
        if let marketCapRank = coin.marketCapRank  {
            let request = Coin.fetchRequest(NSPredicate(format: "marketCapRank == %i", marketCapRank))
            let coins = try context.fetch(request)
            for dbCoin in coins {
                if dbCoin.id != coin.id {
                    dbCoin.marketCapRank = Int64.max
                }
            }
        }
    }
    
    func getCoinsAsync(searchTerm: String, currency: Currency, context: NSManagedObjectContext) async {
        if let url = Endpoint.search(matching: searchTerm).url {
            do {
//                print(url)
                let (data, _) = try await URLSession.shared.data(from: url)
                let searchable = try JSONDecoder().decode(CoingeckoSearch.self, from: data)
                let ids = searchable.coins.map { $0.id }
                await fetchAndStoreCoins(with: ids, currency: currency, context: context)
            } catch {
                print("couldn't fetch search: \(error)")
            }
        } else {
            print("bad url")
        }
    }

    func getCoinsSync(searchTerm: String, currency: Currency, context: NSManagedObjectContext) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            Task {
                await self.getCoinsAsync(searchTerm: searchTerm, currency: currency, context: context)
            }
        }
    }
}
