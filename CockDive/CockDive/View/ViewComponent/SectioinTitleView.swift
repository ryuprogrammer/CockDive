import SwiftUI

struct SectioinTitleView: View {
    
    let text: String
    let isRequired: Bool
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    var body: some View {
        HStack {
            Text(text)
                .font(.headline)
            
            if isRequired {
                Text("必須")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.pink)
                    .frame(
                        width: (window?.screen.bounds.width ?? 40) / 10,
                        height: (window?.screen.bounds.height ?? 24) / 34
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(lineWidth: 2)
                            .foregroundStyle(Color.pink)
                    )
            }
            
            Spacer()
        }
    }
}

#Preview {
    SectioinTitleView(text: "① 写真を追加しよう！", isRequired: true)
}
