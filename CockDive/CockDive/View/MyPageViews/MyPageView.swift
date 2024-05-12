import SwiftUI

struct MyPageView: View {
    
    
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("マイページ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("main"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35)
                            .foregroundStyle(Color.white)
                    })
                }
            }
        }
    }
}

enum SettingViewType {
    case notificationsView
    case privacyPolicyView
    case termsOfServiceView
    case blockList
    case writeReview
    case contactView
    case logoutView
    case deleteAccountView
}

#Preview {
    MyPageView()
}

