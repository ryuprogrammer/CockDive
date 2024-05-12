import SwiftUI

struct TermsOfServiceView: View {
    
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [SettingViewPath]
    
    var body: some View {
        Text("TermsOfServiceView")
    }
}

#Preview {
    struct PreviewView: View {
        @State private var path: [SettingViewPath] = []
        
        var body: some View {
            TermsOfServiceView(path: $path)
        }
    }
    return PreviewView()
}
