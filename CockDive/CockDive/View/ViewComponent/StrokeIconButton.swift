import SwiftUI

struct StrokeIconButton: View {
    // ボタンに表示する文言
    let text: String
    // アイコン
    let icon: String
    // タップ処理
    let action: () -> Void
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    init(text: String, icon: String, action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: (window?.screen.bounds.width ?? 50) / 15,
                        height: (window?.screen.bounds.height ?? 50) / 18
                    )
                    .foregroundStyle(Color.mainColor)
                    .padding(.horizontal)
                Spacer()
                Text(text)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.mainColor)
                    .padding(.horizontal)
                Spacer()
                Spacer()
                    .frame(
                        width: (window?.screen.bounds.width ?? 50) / 15,
                        height: (window?.screen.bounds.height ?? 50) / 18
                    )
            }
            .frame(
                width: (window?.screen.bounds.width ?? 400) - 40,
                height: (window?.screen.bounds.height ?? 60) / 16
            )
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(Color.mainColor)
            )
        })
    }
}

#Preview {
    StrokeIconButton(
        text: "写真を撮る", icon: "camera",
        action: {
            // 何もしない
        }
    )
}
