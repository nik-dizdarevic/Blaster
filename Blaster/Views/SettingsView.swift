//
//  SettingsView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var store: CoinFetcher
    @Environment(\.managedObjectContext) var context
    
    @StateObject var currencyRatesConverter = CurrencyRatesConverter(name: "Default")
    
    @AppStorage("currency") var currency: Currency = .usd
    @AppStorage("startPage") var startPage: Page = .market
    
    var body: some View {
        NavigationStack {
            Form {
                currencyPicker
                startPagePicker
            }
            .navigationTitle("Settings")
            .onChange(of: currency) { [currency] newCurrency in
                Task {
                    await store.fetchAndStoreCoins(currency: newCurrency, context: context)
                    await currencyRatesConverter.convertPortfolio(from: currency, to: newCurrency, context: context)
                }
            }
        }
    }
    
    var currencyPicker: some View {
        Picker(selection: $currency) {
            ForEach(Currency.allCases) { currency in
                Text("\(currency.rawValue.uppercased())")
            }
        } label: {
            Label {
                Text("Currency")
            } icon: {
                FormIcon(image: "bitcoinsign", color: .blue)
            }
        }
    }
    
    var startPagePicker: some View {
        Picker(selection: $startPage) {
            ForEach(Page.allCases) { page in
                Text("\(page.rawValue.capitalized)")
            }
        } label: {
            Label {
                Text("Start Page")
            } icon: {
                FormIcon(image: "house", color: .red)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
