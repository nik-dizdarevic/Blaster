//
//  MyTransaction.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation

struct MyTransaction {
    var coinPrice: Decimal
    var quantity: Decimal
    var date: Date
    var type: TransactionType
    var notes: String
    var total: Decimal {
        get { coinPrice * quantity }
        set { }
    }
}
