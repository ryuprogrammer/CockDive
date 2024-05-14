import SwiftUI

/// 横長の丸みを帯びたボタン
struct LongBarButton: View {
    // ボタンに表示する文言
    let text: String
    // Strokeの有無
    let isStroke: Bool
    // タップ処理
    let action: () -> Void
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    init(text: String, isStroke: Bool, action: @escaping () -> Void) {
        self.text = text
        self.isStroke = isStroke
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
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(lineWidth: 6)
                        .foregroundStyle(isStroke ? Color.white : Color.mainColor)
                        .background(Color.mainColor)
                )
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .padding()
        })
    }
}

#Preview {
    ZStack {
        Color.gray
        
        VStack {
            LongBarButton(
                text: "isStroke: true",
                isStroke: true,
                action: {
                    // 何もしない
                }
            )
            
            LongBarButton(
                text: "isStroke: false",
                isStroke: false,
                action: {
                    // 何もしない
                }
            )
        }
    }
}

