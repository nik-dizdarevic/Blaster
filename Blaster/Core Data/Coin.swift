//
//  Coin.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation
import CoreData

extension Coin {
    
    public var id: String {
        get { id_! }
        set { id_ = newValue }
    }
        
    var name: String {
        get { name_! }
        set { name_ = newValue }
    }
    
    var symbol: String {
        get { symbol_! }
        set { symbol_ = newValue }
    }
    
    var image: String {
        get { image_! }
        set { image_ = newValue }
    }
    
    var ath: Decimal {
        get { ath_?.decimalValue ?? 0 }
        set { ath_ = newValue as NSDecimalNumber }
    }
    
    var athChangePercentage: Decimal {
        get { athChangePercentage_?.decimalValue ?? 0 }
        set { athChangePercentage_ = newValue as NSDecimalNumber }
    }
    
    var atl: Decimal {
        get { atl_?.decimalValue ?? 0 }
        set { atl_ = newValue as NSDecimalNumber }
    }
    
    var atlChangePercentage: Decimal {
        get { atlChangePercentage_?.decimalValue ?? 0 }
        set { atlChangePercentage_ = newValue as NSDecimalNumber }
    }
    
    var circulatingSupply: Decimal {
        get { circulatingSupply_?.decimalValue ?? 0 }
        set { circulatingSupply_ = newValue as NSDecimalNumber }
    }
    
    var currentPrice: Decimal {
        get { currentPrice_?.decimalValue ?? 0 }
        set { currentPrice_ = newValue as NSDecimalNumber }
    }
    
    var high24H: Decimal {
        get { high24H_?.decimalValue ?? 0 }
        set { high24H_ = newValue as NSDecimalNumber }
    }
    
    var low24H: Decimal {
        get { low24H_?.decimalValue ?? 0 }
        set { low24H_ = newValue as NSDecimalNumber }
    }
    
    var marketCap: Decimal {
        get { marketCap_?.decimalValue ?? 0 }
        set { marketCap_ = newValue as NSDecimalNumber }
    }
    
    var priceChange24H: Decimal {
        get { priceChange24H_?.decimalValue ?? 0 }
        set { priceChange24H_ = newValue as NSDecimalNumber }
    }
    
    var priceChangePercentage24H: Decimal {
        get { priceChangePercentage24H_?.decimalValue ?? 0 }
        set { priceChangePercentage24H_ = newValue as NSDecimalNumber }
    }
    
    var totalVolume: Decimal {
        get { totalVolume_?.decimalValue ?? 0 }
        set { totalVolume_ = newValue as NSDecimalNumber }
    }
    
    var maxSupply: Decimal {
        get { maxSupply_?.decimalValue ?? 0 }
        set { maxSupply_ = newValue as NSDecimalNumber }
    }
    
    var totalSupply: Decimal {
        get { totalSupply_?.decimalValue ?? 0 }
        set { totalSupply_ = newValue as NSDecimalNumber }
    }
    
    var charts: Set<Chart> {
        get { (charts_ as? Set<Chart>) ?? [] }
        set { charts_ = newValue as NSSet }
    }
    
    var transactions: Set<Transaction> {
        get { (transactions_ as? Set<Transaction>) ?? [] }
        set { transactions_ = newValue as NSSet }
    }
    
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Coin> {
        let request = NSFetchRequest<Coin>(entityName: "Coin")
        request.sortDescriptors = [NSSortDescriptor(key: "marketCapRank", ascending: true)]
        request.predicate = predicate
        return request
    }
    
    @discardableResult
    static func update(from coingeckoCoin: CoingeckoCoin, in context: NSManagedObjectContext) -> Coin {
        let request = fetchRequest(NSPredicate(format: "id_ == %@", coingeckoCoin.id))
        let results = (try? context.fetch(request)) ?? []
        let coin = results.first ?? Coin(context: context)
        coin.ath = coingeckoCoin.ath ?? 0
        coin.athChangePercentage = coingeckoCoin.athChangePercentage ?? 0
        coin.atl = coingeckoCoin.atl ?? 0
        coin.atlChangePercentage = coingeckoCoin.atlChangePercentage ?? 0
        coin.circulatingSupply = coingeckoCoin.circulatingSupply ?? 0
        coin.currentPrice = coingeckoCoin.currentPrice ?? 0
        coin.high24H = coingeckoCoin.high24H ?? 0
        coin.id = coingeckoCoin.id
        coin.image = coingeckoCoin.image
        coin.low24H = coingeckoCoin.low24H ?? 0
        coin.marketCap = coingeckoCoin.marketCap ?? 0
        coin.marketCapRank = coingeckoCoin.marketCapRank ?? Int64.max
        coin.name = coingeckoCoin.name
        coin.priceChange24H = coingeckoCoin.priceChange24H ?? 0
        coin.priceChangePercentage24H = coingeckoCoin.priceChangePercentage24H ?? 0
        coin.symbol = coingeckoCoin.symbol
        coin.totalVolume = coingeckoCoin.totalVolume ?? 0
        coin.maxSupply = coingeckoCoin.maxSupply ?? 0
        coin.totalSupply = coingeckoCoin.totalSupply ?? 0
        coin.updatedAt = coingeckoCoin.updatedAt
        coin.objectWillChange.send()
        coin.holding?.objectWillChange.send()
        coin.holding?.portfolio.objectWillChange.send()
        return coin
    }
    
    @MainActor
    func fetchThumbnail() async {
        if thumbnail == nil {
            if let url = URL(string: image) {
                do {
                    let (imageData, _) = try await URLSession.shared.data(from: url)
                    thumbnail = imageData
                } catch {
                    print("couldn't fetch image from \(url): \(error)")
                }
            }
        }
    }
    
    @MainActor
    func fetchChart(range: ChartRange, currency: Currency) async {
        
        if let url = Endpoint.chart(for: id, matching: range, currency: currency).url {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let coinChart = try JSONDecoder().decode(CoingeckoCoinChart.self, from: data)
                if let context = managedObjectContext {
                    let chart = Chart(context: context)
                    chart.name = range.rawValue
                    for priceAndSummary in coinChart.prices {
                        let priceSummary = PriceSummary(context: context)
                        priceSummary.date = Date(timeIntervalSince1970: (priceAndSummary[0] as NSDecimalNumber).doubleValue / 1000)
                        priceSummary.price = priceAndSummary[1]
                        priceSummary.chart = chart
                    }
                    if let oldChart = self.charts.first(where: { $0.name == chart.name }) {
                        self.charts.remove(oldChart)
                    }
                    self.charts.insert(chart)
                    self.objectWillChange.send()
                    try context.save()
                }
            } catch {
                print("couldn't fetch and save chart data for coin with id - \(id): \(error)")
            }
        } else {
            print("bad url")
        }
    }
    
    func watchListToggle() {
        do {
            watchList.toggle()
            self.objectWillChange.send()
            if let context = managedObjectContext {
                try context.save()
            }
        } catch {
            print("couldn't save watchlist change")
        }
    }
}
