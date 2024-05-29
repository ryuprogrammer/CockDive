import SwiftUI

struct TermsOfServiceView: View {
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
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolBarBackButtonView {
                        path.removeLast()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("利用規約")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .font(.title3)
                }
            }
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView(path: .constant([]))
    }
}
