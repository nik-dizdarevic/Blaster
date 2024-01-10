//
//  CoinDetailedView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI
import CoreData
import Charts

struct CoinDetailedView: View {
    
    @ObservedObject var coin: Coin
    @EnvironmentObject var store: CoinFetcher
    
    @Environment(\.managedObjectContext) var context
    
    @AppStorage("currency") var currency: Currency = .usd
    
    @State private var transaction = false

    
    init(coin: Coin) {
        self.coin = coin
        _coinsAmount = State(wrappedValue: 1)
        _coinsCost = State(wrappedValue: (coin.currentPrice as NSDecimalNumber).doubleValue)
    }

    var body: some View {
        List {
            priceSection
            conversionSection
            detailedInfoSection
        }
        .navigationTitle("\(coin.name) (\(coin.symbol.uppercased()))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        coin.watchListToggle()
                    } label: {
                        Image(systemName: coin.watchList ? "star.fill" : "star")
                            .imageScale(.medium)
                    }
                    Button {
                        transaction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                .foregroundColor(.accentColor)
            }
        }
        .sheet(isPresented: $transaction) {
            TransactionView(coin: coin)
        }
        .task {
            await store.fetchAndStoreCoins(with: [coin.id], currency: currency, context: context)
        }
    }
    
    var currencyFormat: Decimal.FormatStyle.Currency {
        .currency(code: currency.rawValue).precision(.fractionLength(0...8))
    }
    
    // MARK: - Price Section
    
    var priceSection: some View {
        Section {
            VStack {
                headline
                title
                Divider()
                content
            }
        }
    }
    
    var headline: some View {
        HStack {
            Text("Current Price")
            Spacer()
        }
        .font(.headline)
        .foregroundColor(.gray)
    }
    
    var title: some View {
        HStack {
            Text("\(coin.currentPrice, format: currencyFormat)")
            Spacer()
        }
        .font(.title.weight(.bold))
        .padding(.bottom)
    }
    
    @ViewBuilder
    var content: some View {
        VStack {
            HStack(spacing: 0) {
                Text("24H Change")
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: coin.priceChange24H < 0 ? "minus" : "plus")
                    .scaleEffect(DrawingConstants.plusMinusScale)
                    .foregroundColor(coin.priceChange24H < 0 ? .myOrange : .myGreen)
                Text("\(abs(coin.priceChange24H), format: currencyFormat)")
            }
            HStack(spacing: 0) {
                Text("24H Percentage Change")
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "triangle.fill")
                    .scaleEffect(DrawingConstants.triangleScale)
                    .rotationEffect(coin.priceChangePercentage24H < 0 ? .degrees(180) : .degrees(0))
                    .foregroundColor(coin.priceChangePercentage24H < 0 ? .myOrange : .myGreen)
                Text("\(abs(coin.priceChangePercentage24H/100), format: .percent.precision(.fractionLength(0...2)))")
            }
        }
        .font(.callout)
        .padding(.bottom)
        chart
    }
    
    // MARK: Chart
    
    @State private var range: ChartRange = .one

    var unit: Calendar.Component {
        switch range {
        case .one:
            return .minute
        case .fourteen, .thirty:
            return .hour
        case .max:
            return .day
        }
    }

    var xValues: AxisMarkValues {
        switch range {
        case .one:
            return .stride(by: .hour, count: 5)
        case .fourteen:
            return .stride(by: .day, count: 3)
        case .thirty:
            return .stride(by: .day, count: 6)
        case .max:
            return .stride(by: .year, count: 2)
        }
    }

    var format: Date.FormatStyle {
        switch range {
        case .one:
            return .dateTime.hour()
        case .fourteen, .thirty:
            return .dateTime.month().day()
        case .max:
            return .dateTime.year()
        }
    }

    var data: [PriceSummary] {
        coin.charts.filter({ $0.name == range.rawValue }).first?.priceSummaries ?? []
    }
    
    var chart: some View {
        VStack {
            Picker("Range", selection: $range) {
                Text("24h").tag(ChartRange.one)
                Text("14d").tag(ChartRange.fourteen)
                Text("30d").tag(ChartRange.thirty)
                Text("Max").tag(ChartRange.max)
            }
            .padding(.bottom)
            .pickerStyle(.segmented)
            .onChange(of: range) { range in
                Task {
                    await coin.fetchChart(range: range, currency: currency)
                }
            }
            Charts.Chart(data, id: \.date) { summary in
                LineMark(
                    x: .value("Time", summary.date, unit: unit),
                    y: .value("Price", summary.price)
                )
            }
            .frame(height: 250)
            .chartYScale(domain: (data.map({ $0.price }).min() ?? 0)...(data.map({ $0.price }).max() ?? 100000))
            .chartXAxis {
                AxisMarks(values: xValues) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(
                        format: format
                    )
                }
            }
        }
    }
    
    // MARK: - Conversion Section
    
    @State private var coinsAmount: Double
    @State private var coinsCost: Double
    
    @FocusState private var isAmountFocused: Bool
    @FocusState private var isCostFocused: Bool
    
    var conversionSection: some View {
        Section {
            Group {
                HStack {
                    TextField("\(coin.symbol.uppercased())", value: $coinsAmount, format: .number.precision(.fractionLength(0...8)))
                        .onSubmit {
                            if coinsAmount < 0 { self.coinsAmount = abs(coinsAmount) }
                        }
                        .focused($isAmountFocused)
                    Stepper(value: $coinsAmount, step: 1) {
                        EmptyView()
                    }
                }
                HStack {
                    TextField(currency.rawValue.uppercased(), value: $coinsCost, format: .currency(code: currency.rawValue).precision(.fractionLength(0...8)))
                        .onSubmit {
                            if coinsCost < 0 { self.coinsCost = abs(coinsCost) }
                        }
                        .focused($isCostFocused)
                    Stepper(value: $coinsCost, step: 1) {
                        EmptyView()
                    }
                }
            }
            .font(.callout)
            .onChange(of: coinsAmount) { input in
                if !isCostFocused {
                    coinsCost = abs(input) * (coin.currentPrice as NSDecimalNumber).doubleValue
                }
            }
            .onChange(of: coinsCost) { input in
                if !isAmountFocused {
                    coinsAmount = abs(input)/(coin.currentPrice as NSDecimalNumber).doubleValue
                }
            }
            .onChange(of: coin.currentPrice) { price in
                coinsAmount = coinsAmount
                coinsCost = coinsAmount * (price as NSDecimalNumber).doubleValue
            }
        } header: {
            Text("Convert \(coin.symbol.uppercased()) to USD")
        }
    }
    
    // MARK: - Detailed Info Section

    var detailedInfoSection: some View {
        Section {
            Group {
                HStack {
                    Text("Market Cap Rank")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(coin.marketCapRank != Int64.max ? "\(coin.marketCapRank)" : "N/A")
                }
                HStack {
                    Text("Market Cap")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(coin.marketCap != 0 ? "\(coin.marketCap, format: currencyFormat)": "N/A")
                }
                HStack {
                    Text("24H Trading Volume")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(coin.totalVolume != 0 ? "\(coin.totalVolume, format: currencyFormat)" : "N/A")
                }
                HStack {
                    Text("24H High")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(coin.high24H != 0 ? "\(coin.high24H, format: currencyFormat)" : "N/A")
                }
                HStack {
                    Text("24H Low")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(coin.low24H != 0 ? "\(coin.low24H, format: currencyFormat)" : "N/A")
                }
                HStack {
                    Text("Circulating Supply")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(coin.circulatingSupply != 0 ? "\(coin.circulatingSupply, format: .number.precision(.fractionLength(0...8)))" : "?")
                }
                HStack {
                    Text("Total Supply")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(coin.totalSupply != 0 ? "\(coin.totalSupply, format: .number.precision(.fractionLength(0...8)))" : "?")
                }
                HStack {
                    Text("Max Supply")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(coin.maxSupply != 0 ? "\(coin.maxSupply, format: .number.precision(.fractionLength(0...8)))" : "?")
                }
                HStack {
                    Text("All-Time High")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(coin.ath, format: currencyFormat)")
                    Text("\((coin.athChangePercentage/100), format: .percent.precision(.fractionLength(0...1)))")
                        .foregroundColor(coin.athChangePercentage < 0 ? .myOrange : .myGreen)
                }
                HStack {
                    Text("All-Time Low")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(coin.atl, format: currencyFormat)")
                    Text("\((coin.atlChangePercentage/100), format: .percent.precision(.fractionLength(0...1)))")
                        .foregroundColor(coin.atlChangePercentage < 0 ? .myOrange : .myGreen)
                }
            }
            .font(.subheadline)
        } header: {
            Text("Price Statistics")
        }
    }
    
    // MARK: - Drawing Constants

    private struct DrawingConstants {
        static let triangleScale: CGFloat = 0.4
        static let plusMinusScale: CGFloat = 0.6
    }
    
}

struct CoinDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        CoinDetailedView(coin: Coin())
    }
}
