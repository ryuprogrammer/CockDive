import SwiftUI

struct MainView: View {
    @State private var viewSelection: ViewType = .cockCard
    var body: some View {
        TabView(selection: $viewSelection) {
            CockCardsView()
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

enum ViewType {
    case cockCard
    case home
}

#Preview {
    MainView()
}
