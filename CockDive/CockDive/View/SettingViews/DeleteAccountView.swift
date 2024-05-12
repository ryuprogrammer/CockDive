import SwiftUI

struct DeleteAccountView: View {
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [SettingViewPath]
    
    var body: some View {
        Text("DeleteAccountView")
    }
}

#Preview {
    struct PreviewView: View {
        @State private var path: [SettingViewPath] = []
        
        var body: some View {
            DeleteAccountView(path: $path)
        }
    }
    return PreviewView()
}
