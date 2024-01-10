//
//  Transaction.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation
import CoreData

extension Transaction {
    
    var coinPrice: Decimal {
        get { coinPrice_?.decimalValue ?? 0 }
        set { coinPrice_ = newValue as NSDecimalNumber }
    }
    
    var quantity: Decimal {
        get { quantity_?.decimalValue ?? 0 }
        set { quantity_ = newValue as NSDecimalNumber }
    }
    
    var type: TransactionType {
        get { TransactionType(rawValue: (type_ ?? "buy")) ?? .buy }
        set { type_ = newValue.rawValue }
    }
    
    var date: Date {
        get { date_! }
        set { date_ = newValue }
    }
    
    var coin: Coin {
        get { coin_! }
        set { coin_ = newValue }
    }
    
    var portfolio: Portfolio {
        get { portfolio_! }
        set { portfolio_ = newValue }
    }
    
    var total: Decimal {
        get { coinPrice * quantity }
        set { }
    }
    
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Transaction> {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.sortDescriptors = [NSSortDescriptor(key: "date_", ascending: true)]
        request.predicate = predicate
        return request
    }
    
    @discardableResult
    static func create(from transactionState: MyTransaction, for coin: Coin, in context: NSManagedObjectContext) -> Transaction {
        
        let portfolio = Portfolio.get(context: context)
        let holding = Holding.get(for: coin, in: portfolio, context: context)
        
        switch transactionState.type {
        case .buy:
            portfolio.totalSpent += transactionState.total
            holding.amount += transactionState.quantity
        case .sell:
            portfolio.totalProceeds += transactionState.total
            holding.amount -= transactionState.quantity
        }
        
        let transaction = Transaction(context: context)
        transaction.coinPrice = transactionState.coinPrice
        transaction.quantity = transactionState.quantity
        transaction.date = transactionState.date
        transaction.type = transactionState.type
        transaction.notes_ = transactionState.notes
        transaction.coin = coin
        transaction.portfolio = portfolio
                
        transaction.objectWillChange.send()
        portfolio.objectWillChange.send()
        holding.objectWillChange.send()
        
        return transaction
    }
}
