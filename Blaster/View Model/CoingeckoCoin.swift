//
//  CoingeckoCoin.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation

struct CoingeckoCoin: Identifiable, Codable, Hashable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Decimal?
    let marketCap: Decimal?
    let marketCapRank: Int64?
    let fullyDilutedValuation: Decimal?
    let totalVolume: Decimal?
    let high24H: Decimal?
    let low24H: Decimal?
    let priceChange24H: Decimal?
    let priceChangePercentage24H: Decimal?
    let marketCapChange24H: Decimal?
    let marketCapChangePercentage24H: Decimal?
    let circulatingSupply: Decimal?
    let totalSupply: Decimal?
    let maxSupply: Decimal?
    let ath: Decimal?
    let athChangePercentage: Decimal?
    let athDate: String?
    let atl: Decimal?
    let atlChangePercentage: Decimal?
    let atlDate: String?
    let roi: Roi?
    let lastUpdated: String?
    
    var updatedAt: Date? {
        if let lastUpdated = lastUpdated {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: lastUpdated)
        }
        return nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case roi
        case lastUpdated = "last_updated"
    }
    
}

struct Roi: Codable, Hashable {
    let times: Decimal
    let currency: String
    let percentage: Decimal
}
