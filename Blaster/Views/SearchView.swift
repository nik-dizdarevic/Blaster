//
//  SearchView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var store: CoinFetcher
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var context
    
    var type: SearchType
    
    @AppStorage("currency") var currency: Currency = .usd
    
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ListView(searchText: searchText, type: type)
                .navigationTitle("Search")
                .searchable(text: $searchText)
                .autocorrectionDisabled(true)
                .navigationBarTitleDisplayMode(type == .normal ? .automatic : .inline)
                .toolbar {
                    if type != .normal {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                dismiss()
                            }
                        }
                    }
                }
                .onChange(of: searchText) { searchText in
                    if !searchText.allSatisfy({ $0.isWhitespace }) {
                        store.getCoinsSync(searchTerm: searchText, currency: currency, context: context)
                    }
                }
        }
    }
    
}


struct ListView: View {
            
    @FetchRequest var coins: FetchedResults<Coin>
    
    @State private var alertText = ""
    @State private var showAlert = false
    
    var searchText: String
    
    var type: SearchType
    
    init(searchText: String, type: SearchType) {
        self.searchText = searchText
        _coins = FetchRequest(fetchRequest: Coin.fetchRequest(NSPredicate(format: "name_ CONTAINS[c] %@ OR symbol_ CONTAINS[c] %@", searchText, searchText)))
        self.type = type
    }
    
    var body: some View {
        List {
            ForEach(coins) { coin in
                switch type {
                case .normal:
                    NavigationLink {
                        CoinDetailedView(coin: coin)
                    } label: {
                        CoinSearchView(coin: coin, alertText: $alertText, showAlert: $showAlert, type: type)
                    }
                case .portfolio, .watchlist:
                    CoinSearchView(coin: coin, alertText: $alertText, showAlert: $showAlert, type: type)
                }
            }
        }
        .overlay() {
            if showAlert { myAlert }
        }
    }
    
    var myAlert: some View {
        VStack {
            Spacer()
            Spacer()
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                    .opacity(DrawingConstants.alertOpacity)
                Text(alertText)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(width: DrawingConstants.alertWidth, height: DrawingConstants.alertHeight)
            .foregroundColor(.black)
            Spacer()
        }
        .transition(.opacity)
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 20
        static let alertOpacity: CGFloat = 0.5
        static let alertWidth: CGFloat = 250
        static let alertHeight: CGFloat = 50
    }
    
}
