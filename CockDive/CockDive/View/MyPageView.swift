import SwiftUI

struct MyPageView: View {
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "person")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("20件投稿")
                        Text("フォロー200人")
                        Text("フォロワー200人")
                    }
                    Spacer()
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
