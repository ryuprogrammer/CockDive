import SwiftUI

struct ToolBarBackButtonView: View {
    // タップ処理
    let action: () -> Void
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.white)
                Text("戻る")
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .font(.title3)
            }
        })
    }
}

#Preview {
    ZStack {
        Color.mainColor
        
        ToolBarBackButtonView(
            action: {
                // 何もしない
            }
        )
    }
}

