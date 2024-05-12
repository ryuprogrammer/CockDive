import SwiftUI

struct ContactView: View {
    
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [SettingViewPath]
    
    var body: some View {
        Text("ContactView")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color("main"), for: .navigationBar)
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
    struct PreviewView: View {
        @State private var path: [SettingViewPath] = []
        
        var body: some View {
            ContactView(path: $path)
        }
    }
    return PreviewView()
}
