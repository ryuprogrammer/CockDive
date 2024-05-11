import SwiftUI

struct AddCockView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("写真")
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 100)
            }
            .navigationTitle("ご飯を投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    AddCockView()
}
