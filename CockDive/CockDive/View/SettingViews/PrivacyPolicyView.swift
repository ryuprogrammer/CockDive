import SwiftUI

struct PrivacyPolicyView: View {
    
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [SettingViewPath]
    
    var body: some View {
        Text("ProvacyPolicyView")
    }
}

#Preview {
    struct PreviewView: View {
        @State private var path: [SettingViewPath] = []
        
        var body: some View {
            PrivacyPolicyView(path: $path)
        }
    }
    return PreviewView()
}
