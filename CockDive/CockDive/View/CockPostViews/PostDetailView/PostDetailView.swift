import SwiftUI

struct PostDetailView: View {
    @State private var userName: String = "momo"
    @State private var title: String = "定食"
    @State private var explain: String = """
ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入
"""
    
    @State private var isLike: Bool = false
    @State private var likeCount: Int = 200
    
    // コメント
    @State private var comment: String = ""
    
    // TabBar用
    @State var flag: Visibility = .hidden
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockPostViewPath]
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    // キーボード制御
    @FocusState private var keybordFocuse: Bool
    
    var body: some View {
        ZStack {
            List {
                VStack {
                    HStack {
                        Image("cockImage")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: (window?.screen.bounds.width ?? 50) / 12,
                                height: (window?.screen.bounds.width ?? 50) / 10
                            )
                            .clipShape(Circle())
                        
                        Text("\(userName)さん")
                        
                        Spacer()
                        
                        StrokeButton(text: "フォロー", size: .small) {
                            
                        }
                        .onTapGesture {
                            print("フォロー処理")
                        }
                    }
                    
                    ZStack {
                        Image("cockImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    
                    Text(explain)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                PostCommentView()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    // コメント入力欄
                    DynamicHeightTextEditorView(
                        text: $comment,
                        placeholder: "コメントしよう！",
                        maxHeight: 200
                    )
                    
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "paperplane.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 34)
                            .foregroundStyle(Color.white)
                    })
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(Color.mainColor)
            }
        }
        // TabBar非表示
        .toolbar(flag, for: .tabBar)
        // 戻るボタン非表示
        .navigationBarBackButtonHidden(true)
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("main"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            // 戻るボタン
            ToolbarItem(placement: .topBarLeading) {
                ToolBarBackButtonView {
                    path.removeLast()
                }
            }
            
            // タイトル
            ToolbarItem(placement: .principal) {
                Text(title)
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .font(.title3)
            }
            
            // 通報
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25)
                    .foregroundStyle(Color.white)
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State private var path: [CockPostViewPath] = []
        
        var body: some View {
            NavigationStack {
                PostDetailView(path: $path)
            }
        }
    }
    return PreviewView()
}
