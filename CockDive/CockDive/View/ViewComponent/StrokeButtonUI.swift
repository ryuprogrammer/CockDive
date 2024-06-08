import SwiftUI

/// 横長の丸みを帯びたボタン
struct StrokeButtonUI: View {
    // ボタンに表示する文言
    let text: String
    // サイズ
    let size: ButtonSize
    // 背景を埋める
    let isFill: Bool
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    var body: some View {
        if size == .small {
            if isFill {
                Text(text)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(Color.mainColor)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            } else {
                Text(text)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.mainColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(Color.whiteBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(lineWidth: 1.5)
                            .foregroundStyle(Color.mainColor)
                    )
            }
        } else {
            Text(text)
                .fontWeight(.bold)
                .foregroundStyle(Color.mainColor)
                .frame(
                    width: (window?.screen.bounds.width ?? 400) - 40,
                    height: (window?.screen.bounds.height ?? 800) / 16
                )
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(Color.mainColor)
                )
        }
    }
}

#Preview {
    VStack {
        StrokeButtonUI(
            text: "ボタン",
            size: .small,
            isFill: false
        )
        
        StrokeButtonUI(
            text: "ボタン",
            size: .small,
            isFill: true
        )
        
        StrokeButtonUI(
            text: "ボタン",
            size: .large,
            isFill: false
        )
        
        StrokeButtonUI(
            text: "ボタン",
            size: .large,
            isFill: true
        )
    }
}

enum ButtonSize {
    case small
    case large
}

