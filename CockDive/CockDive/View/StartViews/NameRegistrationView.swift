import SwiftUI
import PhotosUI

struct NameRegistrationView: View {
    // 登録するニックネーム
    @Binding var nickName: String
    // 登録ボタンの処理
    let registrationAction: () -> Void
    
    // MARK: - その他
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    var screenWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.width
        }
        return 400
    }

    var body: some View {
        ZStack {
            Color.mainColor
                .ignoresSafeArea(.all)
            VStack {
                Spacer()
                Text("ニックネームを入力してね！")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)

                // 名前入力欄
                TextField("8文字以内で入力！", text: $nickName)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal, 20)

                Spacer()

                LongBarButton(text: "次へ", isStroke: true) {
                    registrationAction()
                }

                Spacer()
                    .frame(height: 100)
            }
        }
    }
}

#Preview {
    NameRegistrationView(nickName: .constant("ニックネーム")) {
        
    }
}
