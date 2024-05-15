import SwiftUI

struct MainTabView: View {
    // TabViewのViewSelection
    @State private var viewSelection: ViewType = .cockCard
    var body: some View {
        TabView(selection: $viewSelection) {
            CockPostView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("ご飯")
                }
                .tag(ViewType.cockCard)
            
            MyPageView()
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

#Preview {
    MainTabView()
}

