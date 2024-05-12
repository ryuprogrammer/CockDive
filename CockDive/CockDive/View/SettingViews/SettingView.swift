import SwiftUI

struct SettingView: View {
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [SettingViewPath]
    
    var body: some View {
        List {
            Section {
                NavigationLinkButtonView(text: "お知らせ") {
                    path.append(.newsView)
                }
                
                NavigationLinkButtonView(text: "プライバシーポリシー") {
                    path.append(.privacyPolicyView)
                }
                
                NavigationLinkButtonView(text: "利用規約") {
                    path.append(.termsOfServiceView)
                }
            } header: {
                Text("アプリ情報")
            }
            
            Section {
                NavigationLinkButtonView(text: "ブロックリスト") {
                    path.append(.blockListView)
                }
            } header: {
                Text("友達")
            }
            
            Section {
                NavigationLinkButtonView(text: "レビューを書く") {
                    path.append(.contactView)
                }
                
                NavigationLinkButtonView(text: "アプリをシェア") {
                    path.append(.contactView)
                }
                
                NavigationLinkButtonView(text: "お問合せ") {
                    path.append(.contactView)
                }
            } header: {
                Text("フィードバック")
            }
            
            Section {
                NavigationLinkButtonView(text: "ログアウト") {
                    path.append(.logoutView)
                }
                
                NavigationLinkButtonView(text: "退会") {
                    path.append(.deleteAccountView)
                }
            } header: {
                Text("アカウント")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color("main"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ToolBarBackButtonView {
                    path.removeLast()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("設定")
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .font(.title3)
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State private var path: [SettingViewPath] = []
        
        var body: some View {
            SettingView(path: $path)
        }
    }
    return PreviewView()
}
