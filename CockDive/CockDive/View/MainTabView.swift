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
                    Image(systemName: "fork.knife")
                    Text("ご飯")
                }
                .tag(ViewType.cockCard)
            
            MyPageView(cockCardNavigationPath: $myPageNavigationPath)
                .tabItem {
                    Image(systemName: "house")
                    Text("ホーム")
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
    case detailView(postData: PostElement, firstLike: Bool, firstFollow: Bool)
    /// プロフィール
    case profileView(userData: UserElement, showIsFollow: Bool)
}

//enum SettingViewPath {
//    case settingView
//    case newsView
//    case privacyPolicyView
//    case termsOfServiceView
//    case blockListView
//    case contactView
//    case logoutView
//    case deleteAccountView
//}

#Preview {
    MainTabView()
}

