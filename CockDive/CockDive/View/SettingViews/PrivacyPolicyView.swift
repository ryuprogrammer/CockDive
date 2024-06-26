import SwiftUI

struct PrivacyPolicyView: View {
    @State private var isLoading = true
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockCardNavigationPath]

    var body: some View {
        ZStack {
            WebView(urlString: "https://minnanogohan.hp.peraichi.com/privacypolicy", isLoading: $isLoading)
                .edgesIgnoringSafeArea(.all)

            if isLoading {
                ProgressView("読み込んでるよ")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("プライバシーポリシー")
            .toolbarColorScheme(.dark)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView(path: .constant([]))
    }
}
