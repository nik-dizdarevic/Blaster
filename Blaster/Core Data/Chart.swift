//
//  Chart.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation

extension Chart {
    
    var name: String {
        get { name_! }
        set { name_ = newValue }
    }
    
    var coin: Coin {
        get { coin_! }
        set { coin_ = newValue }
    }
    
    var priceSummaries: [PriceSummary] {
        get { priceSummaries_?.array as? [PriceSummary] ?? [] }
        set { priceSummaries_ = NSOrderedSet(array: newValue) }
    }
    
}
