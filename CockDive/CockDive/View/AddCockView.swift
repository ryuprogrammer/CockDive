import SwiftUI

struct AddCockView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("追加画面")
            }
            .navigationTitle("ご飯を投稿")
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    AddCockView()
}
