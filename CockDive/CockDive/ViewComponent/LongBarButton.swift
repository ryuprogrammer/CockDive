import SwiftUI

/// 横長の丸みを帯びたボタン
struct LongBarButton: View {
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
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .frame(
                    width: (window?.screen.bounds.width ?? 400) - 50,
                    height: (window?.screen.bounds.height ?? 800) / 15
                )
                .background(Color.mainColor)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .padding()
        })
    }
}

#Preview {
    LongBarButton(
        text: "ボタン",
        action: {
            // 何もしない
        }
    )
}
