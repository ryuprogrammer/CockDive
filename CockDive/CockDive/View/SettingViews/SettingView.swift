import SwiftUI

struct SettingView: View {
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [SettingViewPath]
    
    var body: some View {
        List {
            Button(action: {
                path.append(.newsView)
            }, label: {
                HStack {
                    Text("お知らせ")
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.gray)
                }
            })
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("main"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    struct PreviewView: View {
        @State private var path: [SettingViewPath] = []
        
        var body: some View {
            SettingView(path: $path)
        }
    }
    return PreviewView()
}
