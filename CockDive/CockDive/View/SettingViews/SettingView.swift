import SwiftUI

struct SettingView: View {
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockCardNavigationPath]
    // TabBar用
    @State var flag: Visibility = .hidden
    @State var isShowProfileEditView: Bool = false
    @ObservedObject var settingVM = SettingViewModel()
    // ユーザーデータ
    @State var showUserData: UserElementForUserDefaults? = nil

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
        List {
            Button {
                isShowProfileEditView = true
            } label: {
                HStack {
                    // アイコン写真
                    ImageView(
                        data: showUserData?.iconImage,
                        urlString: showUserData?.iconURL,
                        imageType: .icon
                    )
                    .frame(width: screenWidth / 7, height: screenWidth / 7)
                    .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(showUserData?.nickName ?? "ニックネーム")
                            .font(.title)
                            .foregroundStyle(Color.blackWhite)
                        Text("プロフィールを編集")
                            .foregroundStyle(Color.grayWhite)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.grayWhite)
                }
            }

            Section {
                NavigationLinkButtonView(icon: "circle.lefthalf.filled.inverse", text: "テーマカラー変更") {
                    path.append(.mainColorEditView)
                }
            } header: {
                Text("アプリ設定")
            }

            Section {
                NavigationLinkButtonView(icon: "bell", text: "お知らせ") {
                    path.append(.newsView)
                }
                
                NavigationLinkButtonView(icon: "book.pages", text: "プライバシーポリシー") {
                    path.append(.privacyPolicyView)
                }
                
                NavigationLinkButtonView(icon: "book.pages", text: "利用規約") {
                    path.append(.termsOfServiceView)
                }
            } header: {
                Text("アプリ情報")
            }
            
//            Section {
//                NavigationLinkButtonView(icon: "nosign", text: "ブロックリスト") {
//                    path.append(.blockListView)
//                }
//            } header: {
//                Text("友達")
//            }
            
            Section {
                if let url = URL(string: "https://apps.apple.com/jp/app/id6504010784?action=write-review") {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "star").foregroundStyle(Color.blackWhite)
                            .padding(.trailing, 5)
                            Text("レビューを書く").foregroundStyle(Color.blackWhite)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(Color.grayWhite)
                        }
                    }
                }

                if let url = URL(string: "https://apps.apple.com/jp/app/id6504010784") {
                    ShareLink(item: url) {
                        HStack {
                            Image(systemName: "square.and.arrow.up").foregroundStyle(Color.blackWhite)
                            .padding(.trailing, 5)
                            Text("アプリをシェア").foregroundStyle(Color.blackWhite)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(Color.grayWhite)
                        }
                    }
                }

                NavigationLinkButtonView(icon: "envelope", text: "運営へのお問合せ") {
                    path.append(.contactView)
                }
            } header: {
                Text("フィードバック")
            }

            
            Section {
                NavigationLinkButtonView(icon: "person.crop.circle.badge.minus", text: "ログアウト") {
                    path.append(.logoutView)
                }
                
                NavigationLinkButtonView(icon: "person.crop.circle.badge.xmark", text: "アカウント削除") {
                    path.append(.deleteAccountView)
                }
            } header: {
                Text("アカウント")
            }
        }
        // TabBar非表示
        .toolbar(flag, for: .tabBar)
        .navigationTitle("設定")
        .toolbarColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            FirebaseLog.shared.logScreenView(.settingView)
            settingVM.fetchUserData()
        }
        .onChange(of: settingVM.userData) { userData in
            guard let userData else { return }
            showUserData = userData
        }
        .sheet(isPresented: $isShowProfileEditView) {
            MyProfileEditView()
                .onDisappear {
                    settingVM.fetchUserData()
                }
        }
    }
}

#Preview {
    NavigationStack {
        SettingView(path: .constant([]))
    }
}
