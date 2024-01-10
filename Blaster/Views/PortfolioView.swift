//
//  PortfolioView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

struct PortfolioView: View {
    
    @FetchRequest(fetchRequest: Portfolio.fetchRequest(NSPredicate(format: "TRUEPREDICATE"))) private var portfolio: FetchedResults<Portfolio>
    
    @State private var search = false
        
    var body: some View {
        NavigationStack {
            Group {
                if portfolio.isEmpty {
                    nothing
                } else {
                    ForEach(portfolio) { portfolio in
                        PortfolioDetailsView(portfolio: portfolio)
                    }
                }
            }
            .navigationTitle("Portfolio")
            .toolbar {
                if !(portfolio.first?.holdings.isEmpty ?? true) {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        HStack {
                            EditButton()
                            plusButton
                        }

                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        plusButton
                    }
                }
            }
            .sheet(isPresented: $search) {
                SearchView(type: .portfolio)
            }
        }
    }
    
    var plusButton: some View {
        PlusButton {
            search = true
        }
    }
    
    var nothing: some View {
        VStack {
            Image(systemName: "briefcase.fill")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.gray)
            Text("Nothing Here")
                .font(.title2.weight(.bold))
            Spacer()
                .frame(height: DrawingConstants.frameHeight)
            Text("Add a new coin to get started.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    
    private struct DrawingConstants {
        static let frameHeight: CGFloat = 3
    }
    
}

struct PortfolioDetailsView: View {
    
    @EnvironmentObject var store: CoinFetcher
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var portfolio: Portfolio
    
    @FetchRequest private var holdings: FetchedResults<Holding>
    
    @AppStorage("currency") var currency: Currency = .usd
    @AppStorage("holdingsSort") var holdingsSort: SortType = .value
    
    @Environment(\.colorScheme) var colorScheme
        
    init(portfolio: Portfolio) {
        self.portfolio = portfolio
        _holdings = FetchRequest(fetchRequest: Holding.fetchRequest(NSPredicate(format: "portfolio_ == %@", portfolio)))
    }
    
    var body: some View {
        List {
            portfolioDetailsSection
            holdingsSection
        }
        .task {
            await store.fetchAndStoreCoins(with: ids, currency: currency, context: context)
        }
        .refreshable {
            await store.fetchAndStoreCoins(with: ids, currency: currency, context: context)
        }
    }
    
    var ids: [String] {
        holdings.map { $0.coin.id }
    }
    
    var currencyFormat: Decimal.FormatStyle.Currency {
        .currency(code: currency.rawValue).precision(.fractionLength(0...2))
    }
    
    // MARK: - Portfolio Section
    
    var portfolioDetailsSection: some View {
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
            Text("My Portfolio")
            Spacer()
            Image(systemName: portfolio.redacted ? "eye" : "eye.slash")
                .onTapGesture {
                    withAnimation {
                        portfolio.redactedToggle()
                    }
                }
        }
        .font(.headline)
        .foregroundColor(.gray)
    }
    
    var title: some View {
        HStack {
            Text("\(portfolio.currentValue, format: currencyFormat)")
            Spacer()
        }
        .redacted(reason: portfolio.redacted ? .placeholder : [])
        .font(.title.weight(.bold))
        .padding(.bottom)
    }
    
    var content: some View {
        VStack {
            HStack(spacing: 0) {
                Text("24H Change")
                    .foregroundColor(.gray)
                    .unredacted()
                Spacer()
                Image(systemName: portfolio.valueChange24H < 0 ? "minus" : "plus")
                    .scaleEffect(DrawingConstants.plusMinusScale)
                    .foregroundColor(portfolio.valueChange24H < 0 ? .myOrange : .myGreen)
                Text("\(abs(portfolio.valueChange24H), format: currencyFormat)")
            }
            HStack(spacing: 0) {
                Text("24H Percentage Change")
                    .foregroundColor(.gray)
                    .unredacted()
                Spacer()
                Image(systemName: "triangle.fill")
                    .scaleEffect(DrawingConstants.triangleScale)
                    .rotationEffect(portfolio.valueChangePercentage24H < 0 ? .degrees(180) : .degrees(0))
                    .foregroundColor(portfolio.valueChangePercentage24H < 0 ? .myOrange : .myGreen)
                Text("\(abs(portfolio.valueChangePercentage24H/100), format: .percent.precision(.fractionLength(0...2)))")
            }
            HStack(spacing: 0) {
                Text("Total Profit/Loss")
                    .foregroundColor(.gray)
                    .unredacted()
                Spacer()
                Image(systemName: portfolio.pnl < 0 ? "minus" : "plus")
                    .scaleEffect(DrawingConstants.plusMinusScale)
                    .foregroundColor(portfolio.pnl < 0 ? .myOrange : .myGreen)
                Text("\(abs(portfolio.pnl), format: currencyFormat)")
            }
            HStack(spacing: 0) {
                Text("Total Profit/Loss Percentage")
                    .foregroundColor(.gray)
                    .unredacted()
                Spacer()
                Image(systemName: "triangle.fill")
                    .scaleEffect(DrawingConstants.triangleScale)
                    .rotationEffect(portfolio.pnlPercentage < 0 ? .degrees(180) : .degrees(0))
                    .foregroundColor(portfolio.pnlPercentage < 0 ? .myOrange : .myGreen)
                Text("\(abs(portfolio.pnlPercentage/100), format: .percent.precision(.fractionLength(0...2)))")
            }
        }
        .redacted(reason: portfolio.redacted ? .placeholder : [])
        .font(.callout)
    }
    
    // MARK: - Holdings Section
    
    var holdingsSection: some View {
        Section {
            ForEach(holdings.sorted(by: mySort)) { holding in
                HoldingSummaryView(holding: holding)
                    .redacted(reason: portfolio.redacted ? .placeholder : [])
            }
            .onDelete { indexSet in
                deleteHoldingsAndTransactions(for: indexSet)
            }
        } header: {
            HStack {
                Text("Holdings")
                Spacer()
                menu
            }
        }
    }
    
    var menu: some View {
        Menu {
            Picker(selection: $holdingsSort.animation()) {
                Text("Value")
                    .tag(SortType.value)
                Text("Market Cap Rank")
                    .tag(SortType.marketCapRank)
                Text("Name")
                    .tag(SortType.name)
            } label: {}
            .textCase(nil)
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .imageScale(.small)
                .foregroundColor(.gray)
        }
    }
    
    private func mySort(h1: Holding, h2: Holding) -> Bool {
        switch holdingsSort {
        case .marketCapRank:
            return h1.coin.marketCapRank < h2.coin.marketCapRank
        case .value:
            return (h1.amount * h1.coin.currentPrice) > (h2.amount * h2.coin.currentPrice)
        case .name:
            return h1.coin.name < h2.coin.name
        }
    }
    
    private func deleteHoldingsAndTransactions(for indexSet: IndexSet) {
        do {
            for index in indexSet.sorted(by: >) {
                let request = Transaction.fetchRequest(NSPredicate(format: "coin_ == %@", holdings.sorted(by: mySort)[index].coin))
                let transactions = (try? context.fetch(request)) ?? []
                for transaction in transactions {
                    switch transaction.type {
                    case .buy:
                        portfolio.totalSpent -= transaction.total
                    case .sell:
                        portfolio.totalProceeds -= transaction.total
                    }
                    context.delete(transaction)
                }
                context.delete(holdings.sorted(by: mySort)[index])
            }
            try context.save()
        } catch {
           print("couldn't delete holding \(error)")
        }
    }
    
    // MARK: - Drawing Constants
    
    private struct DrawingConstants {
        static let triangleScale: CGFloat = 0.4
        static let plusMinusScale: CGFloat = 0.6
    }
}

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
    }
}
