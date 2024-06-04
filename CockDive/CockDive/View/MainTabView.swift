import SwiftUI

struct MainTabView: View {
    // TabViewのViewSelection
    @State private var viewSelection: ViewType = .cockCard
    @State private var cockPostNavigationPath: [CockCardNavigationPath] = []
    @State private var myPageNavigationPath: [CockCardNavigationPath] = []

    var body: some View {
        TabView(selection: $viewSelection) {
            CockPostView(cockCardNavigationPath: $cockPostNavigationPath)
                .tabItem {
                    VStack {
                        Image(systemName: "fork.knife")
                        Text("みんなのごはん")
                    }
                    .onTapGesture {
                        cockPostNavigationPath.removeAll()
                    }
                }
                .tag(ViewType.cockCard)
            
            MyPageView(cockCardNavigationPath: $myPageNavigationPath)
                .tabItem {
                    VStack {
                        Image(systemName: "frying.pan")
                        Text("ごはんのきろく")
                    }
                    .onTapGesture {
                        myPageNavigationPath.removeAll()
                    }
                }.tag(ViewType.home)
        }
    }
}

// TabViewのViewSelection
enum ViewType {
    case cockCard
    case home
}

enum CockCardNavigationPath: Hashable {
    /// コメント欄
    case detailView(
        postData: PostElement,
        userData: UserElement?,
        firstLike: Bool,
        firstFollow: Bool,
        parentViewType: ParendViewType?
    )
    /// プロフィール
    case profileView(
        userData: UserElement,
        showIsFollow: Bool
    )

    /// 設定画面
    case settingView
    case newsView
    case privacyPolicyView
    case termsOfServiceView
    case blockListView
    case contactView
    case logoutView
    case deleteAccountView
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

/*
 削除処理したときに、
 親ViewのshowPostも削除するため
 */
enum ParendViewType {
    /// 自分の投稿View
    case myPost
    /// ライクした投稿View
    case likePost
    /// 他の人のプロフィール
    case profilePost
}

#Preview {
    MainTabView()
}

