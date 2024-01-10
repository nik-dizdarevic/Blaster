//
//  CurrencyRate.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation

struct CurrencyRate: Decodable {
    
    var date: String?
    var rate: Decimal?
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        
        init?(intValue: Int) {
            nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        for key in container.allKeys {
            if let rate = try? container.decode(Decimal.self, forKey: key) {
                self.rate = rate
            } else if let date = try? container.decode(String.self, forKey: key) {
                self.date = date
            }
        }
    }
}
