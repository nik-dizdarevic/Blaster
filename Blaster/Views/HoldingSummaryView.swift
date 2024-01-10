//
//  HoldingSummaryView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

struct HoldingSummaryView: View {
    
    @ObservedObject var holding: Holding
    
    @AppStorage("currency") var currency: Currency = .usd
    
    @State private var transaction = false
    
    init(holding: Holding) {
        self.holding = holding
    }
    
    var body: some View {
        HStack {
            if !holding.isFault {
                thumbnail
                nameSymbolAndAmount
                Spacer()
                holdingValueAndPriceInfo
                plus
            }
        }
        .sheet(isPresented: $transaction) {
            TransactionView(coin: holding.coin)
        }
    }
    
    var currencyFormat: Decimal.FormatStyle.Currency {
        .currency(code: currency.rawValue).precision(.fractionLength(0...8))
    }
    
    var thumbnail: some View {
        CoinThumbnail(data: holding.coin.thumbnail, width: DrawingConstants.frameWidth, height: DrawingConstants.frameHeight)
    }
    
    var nameSymbolAndAmount: some View {
        VStack(alignment: .leading) {
            Spacer()
            HStack(alignment: .center) {
                Text(holding.coin.symbol.uppercased())
                Text("x \(holding.amount, format: .number.precision(.fractionLength(0...8)))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(holding.coin.name)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var holdingValueAndPriceInfo: some View {
        VStack(alignment: .trailing) {
            Spacer()
            Text("\(holding.amount * holding.coin.currentPrice, format: currencyFormat)")
            Spacer()
            HStack {
                Text("\(holding.coin.currentPrice, format: currencyFormat)")
                    .foregroundColor(holding.coin.priceChangePercentage24H < 0 ? .myOrange : .myGreen)
                HStack(spacing: 0) {
                    Text("(")
                    Text("al")
                        .opacity(0)
                        .overlay {
                            Image(systemName: "triangle.fill")
                                .scaleEffect(DrawingConstants.scale)
                                .rotationEffect(holding.coin.priceChangePercentage24H < 0 ? .degrees(180) : .degrees(0))
                                .foregroundColor(holding.coin.priceChangePercentage24H < 0 ? .myOrange : .myGreen)
                        }
                    Text("\(abs(holding.coin.priceChangePercentage24H/100), format: .percent.precision(.fractionLength(0...1)))")
                    Text(")")
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var plus: some View {
        Button {
            transaction = true
        } label: {
            Image(systemName: "plus")
        }
        .buttonStyle(.plain)
    }
        
    private struct DrawingConstants {
        static let frameWidth: CGFloat = 30
        static let frameHeight: CGFloat = 30
        static let scale: CGFloat = 0.4
    }
    
}

struct HoldingSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        HoldingSummaryView(holding: Holding())
    }
}
