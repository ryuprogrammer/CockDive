import SwiftUI

struct SettingView: View {
    // ルート階層から受け取った配列パスの参照
//    @Binding var path: [NavigationDestination]
    // TabBar用
    @State var flag: Visibility = .hidden
    
    var body: some View {
        List {
            Section {
                NavigationLinkButtonView(icon: "bell", text: "お知らせ") {
//                    path.append(.newsView)
                }
                
                NavigationLinkButtonView(icon: "book.pages", text: "プライバシーポリシー") {
//                    path.append(.privacyPolicyView)
                }
                
                NavigationLinkButtonView(icon: "book.pages", text: "利用規約") {
//                    path.append(.termsOfServiceView)
                }
            } header: {
                Text("アプリ情報")
            }
            
            Section {
                NavigationLinkButtonView(icon: "nosign", text: "ブロックリスト") {
//                    path.append(.blockListView)
                }
            } header: {
                Text("友達")
            }
            
            Section {
                NavigationLinkButtonView(icon: "star", text: "レビューを書く") {
//                    path.append(.contactView)
                }
                
                NavigationLinkButtonView(icon: "square.and.arrow.up", text: "アプリをシェア") {
//                    path.append(.contactView)
                }
                
                NavigationLinkButtonView(icon: "envelope", text: "お問合せ") {
//                    path.append(.contactView)
                }
            } header: {
                Text("フィードバック")
            }
            
            Section {
                NavigationLinkButtonView(icon: "person.crop.circle.badge.minus", text: "ログアウト") {
//                    path.append(.logoutView)
                }
                
                NavigationLinkButtonView(icon: "person.crop.circle.badge.xmark", text: "退会") {
//                    path.append(.deleteAccountView)
                }
            } header: {
                Text("アカウント")
            }
        }
        // TabBar非表示
        .toolbar(flag, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ToolBarBackButtonView {
//                    path.removeLast()
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
    SettingView()
}
