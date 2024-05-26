import SwiftUI

struct MyPageView: View {
    @ObservedObject var myPageVM = MyPageViewModel()
    // UserDefaultsの基本データ（ニックネーム、自己紹介、アイコン）
    @State var showUserData = UserElementForUserDefaults(nickName: "テスト")
    // UserFriendElement（フォロー、フォロワー）
    @State var showFriendData = UserFriendElement(followCount: 0, follow: [], followerCount: 0, follower: [], block: [], blockedByFriend: [])
    // 投稿データ
    @State var showMyPostData: [(day: Int, post: MyPostModel)] = []
    // 投稿数
    @State var myPostCount: Int = 0

    // 表示している月
    @State private var showDate: Date = Date()

    // 画面遷移用
    @State private var navigationPath: [SettingViewPath] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                MyPageHeaderView(
                    showUserData: $showUserData,
                    postCount: $myPostCount,
                    showFriendData: $showFriendData
                )

                SwipeableTabView(tabs: [
                    (title: "カレンダー", view: AnyView(ImageCalendarView())),
                    (title: "投稿", view: AnyView(Text("投稿"))),
                    (title: "いいね", view: AnyView(Text("いいね")))
                ])
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("マイページ")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .font(.title3)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        navigationPath.append(.settingView)
                    }, label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35)
                            .foregroundStyle(Color.white)
                    })
                }
            }
            .navigationDestination(for: SettingViewPath.self) { value in
                switch value {
                case .settingView:
                    SettingView(path: $navigationPath)
                case .newsView:
                    NewsView(path: $navigationPath)
                case .privacyPolicyView:
                    PrivacyPolicyView(path: $navigationPath)
                case .termsOfServiceView:
                    TermsOfServiceView(path: $navigationPath)
                case .blockListView:
                    BlockListView(path: $navigationPath)
                case .contactView:
                    ContactView(path: $navigationPath)
                case .logoutView:
                    LogoutView(path: $navigationPath)
                case .deleteAccountView:
                    DeleteAccountView(path: $navigationPath)
                }
            }
        }
    }
}

enum SettingViewPath {
    case settingView
    case newsView
    case privacyPolicyView
    case termsOfServiceView
    case blockListView
    case contactView
    case logoutView
    case deleteAccountView
}

#Preview {
    MyPageView()
}
