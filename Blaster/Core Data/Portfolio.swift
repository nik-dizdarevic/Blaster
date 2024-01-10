//
//  Portfolio.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation
import CoreData


extension Portfolio {
    
    var name: String {
        get { name_! }
        set { name_ = newValue }
    }
    
    var totalSpent: Decimal {
        get { totalSpent_?.decimalValue ?? 0 }
        set { totalSpent_ = newValue as NSDecimalNumber }
    }
    
    var totalProceeds: Decimal {
        get { totalProceeds_?.decimalValue ?? 0 }
        set { totalProceeds_ = newValue as NSDecimalNumber }
    }
    
    var currentValue: Decimal {
        holdings
            .map { $0.amount * $0.coin.currentPrice }
            .reduce(0, +)
    }
    
    var value24HAgo: Decimal {
        holdings
            .map { $0.amount * ($0.coin.currentPrice - $0.coin.priceChange24H) }
            .reduce(0, +)
    }
    
    var valueChange24H: Decimal {
        currentValue - value24HAgo
    }
    
    var valueChangePercentage24H: Decimal {
        ((currentValue - value24HAgo) / value24HAgo) * 100
    }
    
    var pnl: Decimal {
        currentValue + totalProceeds - totalSpent
    }
    
    var pnlPercentage: Decimal {
        (pnl / totalSpent) * 100
    }
    
    var transactions: Set<Transaction> {
        get { (transactions_ as? Set<Transaction>) ?? [] }
        set { transactions_ = newValue as NSSet }
    }
    
    var holdings: Set<Holding> {
        get { (holdings_ as? Set<Holding>) ?? [] }
        set { holdings_ = newValue as NSSet }
    }
    
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Portfolio> {
        let request = NSFetchRequest<Portfolio>(entityName: "Portfolio")
        request.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
        request.predicate = predicate
        return request
    }
    
    static func get(context: NSManagedObjectContext) -> Portfolio {
        let request = fetchRequest(NSPredicate(format: "TRUEPREDICATE"))
        let results = (try? context.fetch(request)) ?? []
        if let porfolio = results.first {
            return porfolio
        } else {
            let portfolio = Portfolio(context: context)
            portfolio.name = "My Portfolio"
            portfolio.totalSpent = 0
            portfolio.totalProceeds = 0
            return portfolio
        }
    }
    
    func redactedToggle() {
        do {
            redacted.toggle()
            self.objectWillChange.send()
            if let context = managedObjectContext {
                try context.save()
            }
        } catch {
            print("couldn't toggle redacted")
        }
    }
}
