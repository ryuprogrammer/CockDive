import SwiftUI

struct NewsView: View {
    
    // ルート階層から受け取った配列パスの参照
//    @Binding var path: [NavigationDestination]
    
    var body: some View {
        Text("NewsView")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolBarBackButtonView {
//                        path.removeLast()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("お知らせ")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .font(.title3)
                }
            }
    }
}

#Preview {
    NewsView()
}
