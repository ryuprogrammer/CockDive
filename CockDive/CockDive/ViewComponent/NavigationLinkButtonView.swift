import SwiftUI

/// 横長の丸みを帯びたボタン
struct NavigationLinkButtonView: View {
    // ボタンに表示する文言
    let text: String
    // タップ処理
    let action: () -> Void
    
    init(text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                Text(text)
                    .foregroundStyle(Color.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.gray)
            }
        })
    }
}

#Preview {
    NavigationLinkButtonView(
        text: "ボタン",
        action: {
            // 何もしない
        }
    )
}
