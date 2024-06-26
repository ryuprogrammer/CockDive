import SwiftUI
import PhotosUI

struct NameRegistrationView: View {
    // 登録するニックネーム
    @Binding var nickName: String
    @State private var errorMessage = ""
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
                TextField("2～8文字以内で入力！", text: $nickName)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .foregroundStyle(Color.blackWhite)
                    .tint(Color.white)
                    .padding(.horizontal, 20)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(Color.red)
                        .fontWeight(.bold)
                        .padding(.top, 5)
                }

                Spacer()

                LongBarButton(text: "次へ", isStroke: true) {
                    validateNickName()
                    if errorMessage.isEmpty {
                        registrationAction()
                    }
                }

                Spacer()
                    .frame(height: 100)
            }
        }
        .onAppear {
            nickName = ""
        }
        .onChange(of: nickName) { _ in
            validateNickName()
        }
    }

    private func validateNickName() {
        errorMessage = ""
        if nickName.isEmpty {
            errorMessage = "ニックネームを入力してください"
        } else if nickName.containsNGWord() {
            errorMessage = "不適切な言葉が含まれています"
        } else if nickName.count < 2 || nickName.count > 8 {
            errorMessage = "2文字以上8文字以下で入力してください。"
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var nickName: String = ""
        var body: some View {
            NameRegistrationView(nickName: $nickName) {
                print("登録処理")
            }
        }
    }

    return PreviewView()
}
