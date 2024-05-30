import SwiftUI

struct ContactView: View {
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockCardNavigationPath]
    @State var isLoading: Bool = true

    var body: some View {
        ZStack {
            WebView(urlString: "https://forms.gle/3TWdycdMz7sDwexH7", isLoading: $isLoading)

            if isLoading {
                ProgressView("読み込んでるよ")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .ignoresSafeArea()
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
                Text("お問合せ")
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .font(.title3)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContactView(path: .constant([]))
    }
}

