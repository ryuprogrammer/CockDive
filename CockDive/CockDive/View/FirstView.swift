import SwiftUI

struct FirstView: View {
    // TabViewのViewSelection
    @State private var viewSelection: ViewType = .cockCard
    private var authenticationManager = AuthenticationManager()
    
    var body: some View {
        VStack {
            if authenticationManager.isSignIn {
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
                SingInView()
            }
            
            LongBarButton(text: "開発者ボタン", isStroke: false) {
                
            }
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
