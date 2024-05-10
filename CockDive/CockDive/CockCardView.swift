//
//  CockCardView.swift
//  CockDive
//
//  Created by トム・クルーズ on 2024/05/10.
//

import SwiftUI

struct CockCardView: View {
    @State private var userName: String = "momo"
    @State private var title: String = "定食"
    @State private var explain: String = """
ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入
"""
    
    var body: some View {
        VStack {
            ZStack {
                Image("cockImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                VStack(alignment: .leading) {
                    Image(systemName: "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .foregroundStyle(Color.white)
                }
                .frame(maxWidth: .infinity)
            }
            
            VStack {
                HStack(alignment: .bottom) {
                    Text(title)
                        .font(.title)
                    Spacer()
                    Text("\(userName)さん")
                }
                
                Text(explain)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CockCardView()
}
