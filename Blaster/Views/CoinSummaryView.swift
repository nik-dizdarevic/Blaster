//
//  CoinSummaryView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

struct CoinSummaryView: View {
    
    @ObservedObject var coin: Coin
    
    @AppStorage("currency") var currency: Currency = .usd
        
    var body: some View {
        HStack {
            thumbnail
            nameAndSymbol
            Spacer()
            priceIndicator
        }
    }
    
    var currencyFormat: Decimal.FormatStyle.Currency {
        .currency(code: currency.rawValue).precision(.fractionLength(0...8))
    }
    
    var thumbnail: some View {
        CoinThumbnail(data: coin.thumbnail, width: DrawingConstants.frameWidth, height: DrawingConstants.frameHeight)
    }
    
    var nameAndSymbol: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(coin.name)
            Spacer()
            Text(coin.symbol.uppercased())
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var priceIndicator: some View {
        VStack(alignment: .trailing) {
            Spacer()
            Text("\(coin.currentPrice, format: currencyFormat)")
            Spacer()
            HStack {
                Text("a")
                    .opacity(0)
                    .font(.footnote.weight(.light))
                    .overlay {
                        Image(systemName: "triangle.fill")
                            .scaleEffect(DrawingConstants.scale)
                            .rotationEffect(coin.priceChangePercentage24H < 0 ? .degrees(180) : .degrees(0))
                    }
                Text("\(abs(coin.priceChangePercentage24H/100), format: .percent.precision(.fractionLength(0...1)))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.horizontal)
        .foregroundColor(coin.priceChangePercentage24H < 0 ? .myOrange : .myGreen)
    }
    
    private struct DrawingConstants {
        static let frameWidth: CGFloat = 30
        static let frameHeight: CGFloat = 30
        static let scale: CGFloat = 0.4
    }
}

struct CoinSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        CoinSummaryView(coin: Coin())
    }
}
