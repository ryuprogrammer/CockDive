import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("a")
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("main"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    SettingView()
}
