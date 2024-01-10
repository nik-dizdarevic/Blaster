//
//  PriceSummary.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation

extension PriceSummary {
    
    var date: Date {
        get { date_! }
        set { date_ = newValue }
    }
    
    var price: Decimal {
        get { price_?.decimalValue ?? 0 }
        set { price_ = newValue as NSDecimalNumber }
    }
    
    var chart: Chart {
        get { chart_! }
        set { chart_ = newValue }
    }
    
}
