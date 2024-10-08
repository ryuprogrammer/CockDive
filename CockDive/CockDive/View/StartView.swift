import SwiftUI

struct StartView: View {
    @ObservedObject var startViewModel = StartViewModel()
    // 登録するニックネーム
    @State private var nickName: String = ""
    // 登録するアイコン写真
    @State private var iconImage: UIImage? = nil
    // キーボード制御
    @FocusState private var keybordFocuse: Bool
    
    var body: some View {
        switch startViewModel.userStatus {
        case .signInRequired:
            // サインイン
            SignInView()
                .onAppear {
                    FirebaseLog.shared.logScreenView(.signInView)
                }
        case .nameRegistrationRequired:
            // 名前登録画面
            NameRegistrationView(nickName: $nickName) {
                // アイコン設定画面に画面遷移
                startViewModel.userStatus = .iconRegistrationRequired
            }
            .onAppear {
                FirebaseLog.shared.logScreenView(.nameRegistrationView)
            }
        case .iconRegistrationRequired:
            // アイコン写真登録画面
            IconRegistrationView(uiImage: $iconImage) {
                let iconImageData = iconImage?.castToData()
                // ユーザー登録
                startViewModel.addUser(nickName: nickName, iconImageData: iconImageData)
                // メイン画面に画面遷移
                startViewModel.userStatus = .normalUser
            }
            .onAppear {
                FirebaseLog.shared.logScreenView(.iconRegistrationView)
            }
        case .normalUser:
            // メイン画面
            MainTabView()
        case .bannedUser:
            Text("垢BANしてます。")
        case .loading:
            Text("Loading...")
        }
    }
}

#Preview {
    StartView()
}

