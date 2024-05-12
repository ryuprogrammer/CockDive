//
//  SmallImageView.swift
//  CockDive
//
//  Created by トム・クルーズ on 2024/05/12.
//

import SwiftUI

struct SmallImageView: View {
    let day: Int
    let image: Image = Image("cockImage")
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    var body: some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: (window?.screen.bounds.width ?? 400) / 7 - 5,
                    height: (window?.screen.bounds.height ?? 800) / 10
                )
            
            VStack {
                Spacer()
                
                Text("\(day)日")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(
            width: (window?.screen.bounds.width ?? 400) - 50,
            height: (window?.screen.bounds.height ?? 800) / 10
        )
    }
}

#Preview {
    SmallImageView(day: 12)
}
