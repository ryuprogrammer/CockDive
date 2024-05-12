import SwiftUI

struct MyPageView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
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
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("main"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    MyPageView()
}
