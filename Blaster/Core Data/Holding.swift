//
//  Holding.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation
import CoreData

extension Holding {
    
    var amount: Decimal {
        get { amount_?.decimalValue ?? 0 }
        set { amount_ = newValue as NSDecimalNumber }
    }
    
    var portfolio: Portfolio {
        get { portfolio_! }
        set { portfolio_ = newValue }
    }
    
    var coin: Coin {
        get { coin_! }
        set { coin_ = newValue }
    }
    
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Holding> {
        let request = NSFetchRequest<Holding>(entityName: "Holding")
        request.sortDescriptors = [NSSortDescriptor(key: "amount_", ascending: false)]
        request.predicate = predicate
        return request
    }
    
    static func get(for coin: Coin, in portfolio: Portfolio, context: NSManagedObjectContext) -> Holding {
        let request = fetchRequest(NSPredicate(format: "coin_ = %@", coin))
        let result = (try? context.fetch(request)) ?? []
        if let holding = result.first {
            return holding
        } else {
            let holding = Holding(context: context)
            holding.amount = 0
            holding.coin = coin
            holding.portfolio = portfolio
            return holding
        }
    }
}
