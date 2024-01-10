//
//  CoinSearchView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

struct CoinSearchView: View {
    
    @Environment(\.managedObjectContext) var context

    @ObservedObject var coin: Coin

    @Binding var alertText: String
    @Binding var showAlert: Bool
    
    var type: SearchType
    
    var body: some View {
        HStack {
            thumbnail
            nameSymbol
            Spacer()
            switch type {
            case .normal:
                marketCapRank
            case .watchlist:
                watchlistButton
            case .portfolio:
                portfolioButton
            }
        }
    }
    
    var coinRank: String {
        if type == .watchlist {
            return coin.marketCapRank == Int64.max ? "" : " (#\(coin.marketCapRank))"
        } else {
            return coin.marketCapRank == Int64.max ? "" : "#\(coin.marketCapRank)"
        }
    }
    
    var thumbnail: some View {
        CoinThumbnail(data: coin.thumbnail, width: DrawingConstants.frameWidth, height: DrawingConstants.frameHeight)
    }
    
    var nameSymbol: some View {
        VStack(alignment: .leading) {
            Text(coin.name)
                .font(.callout)
            Text("\(coin.symbol.uppercased())" + (type == .watchlist ? "\(coinRank)" : ""))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical, DrawingConstants.padding)
    }
    
    var marketCapRank: some View {
        Text(coinRank)
            .font(.caption)
            .foregroundColor(.gray)
    }
    
    var watchlistButton: some View {
        Button {
            addToWatchlist()
        } label: {
            Image(systemName: coin.watchList ? "star.fill" : "star")
        }
    }
    
    var portfolioButton: some View {
        Button {
            addToPortfolio()
        } label: {
            marketCapRank
        }
    }
    
    private func addToPortfolio() {
        let transaction = MyTransaction(coinPrice: coin.currentPrice, quantity: 0, date: Date(), type: .buy, notes: "")
        Transaction.create(from: transaction, for: coin, in: context)
        try? context.save()
        withAnimation {
            alertText = "Added \(coin.name) to Portfolio"
            showAlert = true
        }
        withAnimation(.easeInOut.delay(1.5)) {
            showAlert = false
        }
    }
    
    private func addToWatchlist() {
        coin.watchListToggle()
        withAnimation {
            alertText = coin.watchList ? "Added \(coin.name) to Watchlist" : "Removed \(coin.name) from Watchlist"
            showAlert = true
        }
        withAnimation(.easeInOut.delay(1.5)) {
            showAlert = false
        }
    }
    
    private struct DrawingConstants {
        static let frameWidth: CGFloat = 20
        static let frameHeight: CGFloat = 20
        static let scale: CGFloat = 0.4
        static let padding: CGFloat = 1.125
    }
}

struct CoinSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CoinSearchView(coin: Coin(), alertText: .constant("Added ..."), showAlert: .constant(true), type: .normal)
    }
}
