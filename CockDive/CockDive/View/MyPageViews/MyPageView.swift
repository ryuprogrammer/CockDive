import SwiftUI

struct MyPageView: View {
    
    // 画面遷移用
    @State private var navigationPath: [SettingViewPath] = []
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                HStack(alignment: .bottom) {
                    Spacer()
                        .frame(width: 30)
                    VStack {
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                        
                        Text("りゅう")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("20件投稿")
                        Text("フォロー200人")
                        Text("フォロワー200人")
                    }
                    Spacer()
                }
                .padding(20)
                
                Text("自己紹介文自己紹介文自己紹介文自己紹介文自己紹介文自己紹介文自己紹介文自己紹介文自己紹介文自己紹介文自己紹介文")
                    .padding(.horizontal)
                    .onTapGesture {
                        // モーダル遷移して、入力画面へ
                    }
                
                ImageCalendarView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("main"), for: .navigationBar)
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

