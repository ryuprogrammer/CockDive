import SwiftUI

struct FirstView: View {
    // LoginStatus
    @State private var isLogin: Bool = true
    // TabViewのViewSelection
    @State private var viewSelection: ViewType = .cockCard
    
    var body: some View {
        if isLogin {
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
        } else {
            StartView()
        }
    }
}

// TabViewのViewSelection
enum ViewType {
    case cockCard
    case home
}

#Preview {
    FirstView()
}
