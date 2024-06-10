import SwiftUI

struct StrokeIconButtonUI: View {
    // ボタンに表示する文言
    let text: String
    // アイコン
    let icon: String
    // サイズ
    let size: ButtonSize
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    init(text: String, icon: String, size: ButtonSize) {
        self.text = text
        self.icon = icon
        self.size = size
    }
    
    var body: some View {
        if size == .large {
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
                    .font(.title3)
                    .foregroundStyle(Color.mainColor)
                    .padding(.horizontal)
                Spacer()
                Spacer()
                    .frame(
                        width: (window?.screen.bounds.width ?? 50) / 15,
                        height: (window?.screen.bounds.height ?? 50) / 18
                    )
            }
            .background(Color.whiteBlack)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(Color.mainColor)
            )
        } else if size == .small {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: (window?.screen.bounds.width ?? 50) / 20,
                        height: (window?.screen.bounds.width ?? 50) / 20
                    )
                    .foregroundStyle(Color.mainColor)
                    .padding(.leading, 5)
                    .padding(5)
                
                Text(text)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.mainColor)
                    .padding(.trailing, 8)
            }
            .background(Color.whiteBlack)
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
        StrokeIconButtonUI(
            text: "写真を撮る", icon: "camera", size: .large
        )
        
        StrokeIconButtonUI(
            text: "写真を撮る", icon: "camera", size: .small
        )
    }
}
