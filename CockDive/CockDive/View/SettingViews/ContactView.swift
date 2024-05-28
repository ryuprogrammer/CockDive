import SwiftUI

struct ContactView: View {
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockCardNavigationPath]

    var body: some View {
        Text("ContactView")
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
    ContactView(path: .constant([]))
}
