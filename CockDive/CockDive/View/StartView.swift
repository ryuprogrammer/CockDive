import SwiftUI

struct StartView: View {
    @ObservedObject var startViewModel = StartViewModel()
    // 登録するニックネーム
    @State private var nickName: String = ""
    // キーボード制御
    @FocusState private var keybordFocuse: Bool
    
    var body: some View {
        switch startViewModel.userStatus {
        case .signInRequired:
            // サインイン
            SignInView()
        case .registrationRequired:
            // 登録
            RegistrationView(nickName: $nickName) {
                Task {
                    await startViewModel.addUser(nickName: nickName)
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

