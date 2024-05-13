import SwiftUI

/// 横長の丸みを帯びたボタン
struct NavigationLinkButtonView: View {
    // 表示するアイコン
    let icon: String
    // ボタンに表示する文言
    let text: String
    // タップ処理
    let action: () -> Void
    
    init(icon: String, text: String, action: @escaping () -> Void) {
        self.icon = icon
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                Image(systemName: icon)
                
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
        icon: "plus",
        text: "ボタン",
        action: {
            // 何もしない
        }
    )
}
