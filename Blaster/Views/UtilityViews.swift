//
//  UtilityViews.swift
//  Blaster
//
//  Created by Nik Dizdarević on 28/12/2022.
//

import SwiftUI

extension Color {
    static let myGreen = Color("myGreen")
    static let myOrange = Color("myOrange")
}

struct FormIcon: View {
    
    let image: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(color)
            Image(systemName: image)
                .foregroundColor(.white)
                .imageScale(.medium)
            
        }
        .frame(width: 28, height: 28)
    }
    
}

struct PlusButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "plus")
        }
    }
    
}

struct CoinThumbnail: View {
    
    let data: Data?
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        if let data, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
        }
    }
    
}
