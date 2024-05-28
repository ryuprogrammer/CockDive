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
        case .nameRegistrationRequired:
            // 名前登録画面
            NameRegistrationView(nickName: $nickName) {
                // アイコン設定画面に画面遷移
                startViewModel.userStatus = .iconRegistrationRequired
            }
        case .iconRegistrationRequired:
            // アイコン写真登録画面
            IconRegistrationView(uiImage: $iconImage) {
                let iconImageData = iconImage?.castToData()
                Task {
                    // ユーザー登録
                    await startViewModel.addUser(nickName: nickName, iconImageData: iconImageData)
                }
            }
        case .normalUser:
            // メイン画面
            MainTabView()
        case .bannedUser:
            Text("垢BANしてるお")
        case .loading:
            Text("Loading...")
        }
    }
}

#Preview {
    StartView()
}

