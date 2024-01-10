//
//  Page.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation

enum Page: String, CaseIterable, Identifiable {
    case market
    case portfolio
    case watchlist
    case search
    
    var id: Self { self }
}
