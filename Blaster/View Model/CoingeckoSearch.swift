//
//  CoingeckoSearch.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation

struct CoingeckoSearch: Codable {
    let coins: [SearchCoin]
    let exchanges: [Exchange]
    let categories: [Category]
    let nfts: [Nft]
}

struct Category: Codable {
    let id: Int
    let name: String
}

struct SearchCoin: Codable, Identifiable {
    let id, name, apiSymbol, symbol: String
    let marketCapRank: Int?
    let thumb, large: String

    private enum CodingKeys: String, CodingKey {
        case id, name
        case apiSymbol = "api_symbol"
        case symbol
        case marketCapRank = "market_cap_rank"
        case thumb, large
    }
}

struct Exchange: Codable {
    let id, name, marketType: String
    let thumb, large: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case marketType = "market_type"
        case thumb, large
    }
}

struct Nft: Codable {
    let id, name, symbol: String?
    let thumb: String
}
