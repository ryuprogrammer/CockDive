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
            ZStack {
                Color.mainColor
                VStack {
                    Text("みんなのご飯")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    Text("ニックネームを登録")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                    
                    Text("8文字以内で入力してね")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                    
                    // 名前入力欄
                    TextField("ニックネームを入力", text: $nickName)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Sign-In状態なので登録画面に遷移
                    LongBarButton(text: "ユーザー登録", isStroke: true) {
                        withAnimation {
                            authenticationManager.register()
                            print("stats: \(authenticationManager.userStatus)")
                        }
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            .ignoresSafeArea(.all)
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

