import SwiftUI

struct NewsView: View {
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockCardNavigationPath]

    var body: some View {
        Text("まだお知らせはありません、")
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("お知らせ")
            .toolbarColorScheme(.dark)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        NewsView(path: .constant([]))
    }
}
