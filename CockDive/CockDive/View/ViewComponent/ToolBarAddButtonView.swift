import SwiftUI

struct ToolBarAddButtonView: View {
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
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .frame(
                    width: (window?.screen.bounds.width ?? 400) / 5,
                    height: (window?.screen.bounds.height ?? 800) / 28
                )
                .background(Color.mainColor)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 3)
                        .foregroundStyle(Color.white)
                )
        })
    }
}

#Preview {
    ToolBarAddButtonView(
        text: "投稿",
        action: {
            // 何もしない
        }
    )
}

