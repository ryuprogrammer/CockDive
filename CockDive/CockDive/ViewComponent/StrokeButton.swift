import SwiftUI

/// 横長の丸みを帯びたボタン
struct StrokeButton: View {
    // ボタンに表示する文言
    let text: String
    // タップ処理
    let action: () -> Void
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    init(text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Text(text)
                .fontWeight(.bold)
                .foregroundStyle(Color.mainColor)
                .frame(
                    width: (window?.screen.bounds.width ?? 400) / 4,
                    height: (window?.screen.bounds.height ?? 800) / 26
                )
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 1.5)
                        .foregroundStyle(Color.mainColor)
                )
        })
    }
}

#Preview {
    StrokeButton(
        text: "ボタン",
        action: {
            // 何もしない
        }
    )
}
