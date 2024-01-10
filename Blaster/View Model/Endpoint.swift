//
//  Endpoint.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]
    let apiKey = "replace"
    
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.coingecko.com"
        urlComponents.path = path
        urlComponents.queryItems = queryItems + [URLQueryItem(name: "x_cg_demo_api_key", value: apiKey)]
        return urlComponents.url
    }
}

extension Endpoint {
    static func coins(with ids: [String], currency: Currency) -> Endpoint {
        var queryItems = [
            URLQueryItem(name: "vs_currency", value: currency.rawValue),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sparkline", value: "false")
        ]
        
        if !ids.isEmpty {
            let ids = ids.reduce(into: "") {
                $0 += ($1 + ",")
            }
            queryItems.append(URLQueryItem(name: "ids", value: String(ids.dropLast())))
        }
        
        return Endpoint(path: "/api/v3/coins/markets", queryItems: queryItems)
    }
    
    static func search(matching query: String) -> Endpoint {
        Endpoint(
            path: "/api/v3/search",
            queryItems: [
                URLQueryItem(name: "query", value: query)
            ]
        )
    }
    
    static func chart(for id: String, matching range: ChartRange, currency: Currency) -> Endpoint {
        Endpoint(
            path: "/api/v3/coins/" + id + "/market_chart",
            queryItems: [
                URLQueryItem(name: "vs_currency", value: currency.rawValue),
                URLQueryItem(name: "days", value: range.rawValue)
            ]
        )
    }
}
