import SwiftUI

struct CockCardView: View {
    let maxTextCount = 15
    @State private var userName: String = "momo"
    @State private var title: String = "定食"
    @State private var explain: String = """
ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入
"""
    
    @State private var isLike: Bool = false
    @State private var likeCount: Int = 200
    
    // 続きを読む
    @State private var isLineLimit: Bool = false
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockPostViewPath]
    
    var body: some View {
        VStack {
            // アイコン、名前、通報ボタン、フォローボタン
            HStack {
                Image("cockImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: (window?.screen.bounds.width ?? 50) / 10,
                        height: (window?.screen.bounds.width ?? 50) / 10
                    )
                    .clipShape(Circle())
                
                Text("\(userName)さん")
                
                Menu {
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            Image(systemName: "nosign")
                            Spacer()
                            Text("ブロック")
                        }
                    })
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            Image(systemName: "exclamationmark.bubble")
                            Spacer()
                            Text("通報")
                        }
                    })
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.primary)
                }
                
                Spacer()
                StrokeButton(text: "フォロー") {
                    
                }
            }
            
            // 写真
            Image("cockImage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            // タイトル、コメントへの遷移ボタン、ハート
            HStack(alignment: .top, spacing: 20) {
                Text(title)
                    .font(.title)
                
                Spacer()
                VStack(spacing: 1) {
                    Image(systemName: "message")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25)
                        .onTapGesture {
                            // コメント画面へ遷移
                            path.append(.postDetailView)
                        }
                    
                    Text(String(likeCount))
                        .font(.footnote)
                }
                
                VStack(spacing: 1) {
                    Image(systemName: isLike ? "heart" : "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25)
                        .foregroundStyle(Color.pink)
                        .onTapGesture {
                            withAnimation {
                                isLike.toggle()
                                if isLike == true {
                                    likeCount -= 1
                                } else {
                                    likeCount += 1
                                }
                            }
                        }
                    
                    Text(String(likeCount))
                        .font(.footnote)
                }
            }
            
            // 説明文
            DynamicHeightCommentView(message: explain, maxTextCount: maxTextCount)
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State private var path: [CockPostViewPath] = []
        
        var body: some View {
            CockCardView(path: $path)
        }
    }
    return PreviewView()
}
