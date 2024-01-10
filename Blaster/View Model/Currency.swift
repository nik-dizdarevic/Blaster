//
//  Currency.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import Foundation

enum Currency: String, CaseIterable, Identifiable {
    case aed, ars, aud
    case bdt, bhd, bmd, brl
    case cad, chf, clp, cny, czk
    case dkk
    case eur
    case gbp
    case hkd, huf
    case idr, ils, inr
    case jpy
    case krw, kwd
    case lkr
    case mmk, mxn, myr
    case ngn, nok, nzd
    case php, pkr, pln
    case rub
    case sar, sek, sgd
    case thb, `try`, twd
    case uah, usd
    case vef, vnd
    case zar
    
    var id: Self { self }
}
