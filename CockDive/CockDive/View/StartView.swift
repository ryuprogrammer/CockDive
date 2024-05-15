import SwiftUI

struct StartView: View {
    @ObservedObject var authenticationManager = AuthenticationManager()
    // 登録するニックネーム
    @State private var nickName: String = ""
    // キーボード制御
    @FocusState private var keybordFocuse: Bool
    
    var body: some View {
        switch authenticationManager.userStatus {
        case .signInRequired:
            // サインイン
            SignInView()
        case .registrationRequired:
            // 登録
            RegistrationView(nickName: $nickName) {
                authenticationManager.register()
            }
        case .normalUser:
            // メイン画面
            MainTabView()
        case .bannedUser:
            Text("垢BANしてるお")
        }
    }
}

// UserStatus
enum UserStatus {
    /// SingInが必要
    case signInRequired
    /// 登録が必要
    case registrationRequired
    /// 通常のユーザー
    case normalUser
    /// 垢BANされたユーザー
    case bannedUser
}

#Preview {
    StartView()
}

