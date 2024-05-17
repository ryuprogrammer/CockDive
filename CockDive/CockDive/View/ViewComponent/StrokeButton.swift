import SwiftUI

/// 横長の丸みを帯びたボタン
struct StrokeButton: View {
    // ボタンに表示する文言
    let text: String
    // サイズ
    let size: ButtonSize
    // タップ処理
    let action: () -> Void
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    init(text: String,size: ButtonSize, action: @escaping () -> Void) {
        self.text = text
        self.action = action
        self.size = size
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            if size == .small {
                Text(text)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.mainColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(lineWidth: 1.5)
                            .foregroundStyle(Color.mainColor)
                    )
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
        })
    }
}

#Preview {
    VStack {
        StrokeButton(
            text: "ボタン",
            size: .small,
            action: {
                // 何もしない
            }
        )
        
        StrokeButton(
            text: "ボタン",
            size: .large,
            action: {
                // 何もしない
            }
        )
    }
}

enum ButtonSize {
    case small
    case large
}

