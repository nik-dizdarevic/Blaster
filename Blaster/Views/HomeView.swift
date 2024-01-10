//
//  HomeView.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

struct HomeView: View {
    
    var startPage: Page
    
    @State private var page: Page
    
    init(startPage: Page) {
        self.startPage = startPage
        _page = State(initialValue: startPage)
    }
    
    var body: some View {
        TabView(selection: $page) {
            CoinsView()
                .tabItem {
                    Label("Market", systemImage: "chart.xyaxis.line")
                }
                .tag(Page.market)
            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "briefcase")
                }
                .tag(Page.portfolio)
            WatchlistView()
                .tabItem {
                    Label("Watchlist", systemImage: "star")
                }
                .tag(Page.watchlist)
            SearchView(type: .normal)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Page.search)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(startPage: .market)
    }
}
