//
//  CurrencyRatesConverter.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI
import CoreData

@MainActor
class CurrencyRatesConverter: ObservableObject {
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    // MARK: - Intent(s)
    
    private func fetchCurrencyRate(current: Currency, goal: Currency) async throws -> Decimal? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "cdn.jsdelivr.net"
        urlComponents.path = "/gh/fawazahmed0/currency-api@1/latest/currencies/\(current)/\(goal).json"
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let rate = try JSONDecoder().decode(CurrencyRate.self, from: data)
        return rate.rate
    }
    
    func convertPortfolio(from current: Currency, to goal: Currency, context: NSManagedObjectContext) async {
        do {
            let rate = try await fetchCurrencyRate(current: current, goal: goal)
            let request = Portfolio.fetchRequest(NSPredicate(format: "TRUEPREDICATE"))
            let results = (try? context.fetch(request)) ?? []
            let portfolio = results.first
            if let rate {
                portfolio?.totalProceeds = (portfolio?.totalProceeds ?? 0) * rate
                portfolio?.totalSpent = (portfolio?.totalSpent ?? 0) * rate
            }
            portfolio?.objectWillChange.send()
            try context.save()
            print("saved to database")
        } catch {
            print("couldn't convert portfolio currency: \(error)")
        }
    }
    
}
