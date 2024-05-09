//
//  CockCardView.swift
//  CockDive
//
//  Created by トム・クルーズ on 2024/05/10.
//

import SwiftUI

struct CockCardView: View {
    @State private var userName: String = "momo"
    @State private var title: String = "カレー"
    
    var body: some View {
        ZStack {
            Image("cockImage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 350, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack {
                Spacer()
                    .frame(height: 230)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 320, height: 50)
                        .foregroundStyle(Color.white.opacity(0.5))
                    
                    
                }
                .padding()
            }
        }
        .frame(width: 350, height: 300)
    }
}

#Preview {
    CockCardView()
}
