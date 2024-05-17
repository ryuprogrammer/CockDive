import SwiftUI

struct CockCardView: View {
    let maxTextCount = 20
    let postData: PostElement
    let cockCardVM = CockCardViewModel()
    @State private var isLike: Bool = false
    // 続きを読む
    @State private var isLineLimit: Bool = false
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockPostViewPath]
    // アイコンのURL
    @State private var iconImageURL: URL?
    // 投稿者の名前
    @State private var nickName: String = "読み込み中..."
    
    var body: some View {
        VStack {
            // アイコン、名前、通報ボタン、フォローボタン
            HStack {
                // アイコン画像のURL
                AsyncImage(url: iconImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: (window?.screen.bounds.width ?? 50) / 10,
                            height: (window?.screen.bounds.width ?? 50) / 10
                        )
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(
                            width: (window?.screen.bounds.width ?? 50) / 10,
                            height: (window?.screen.bounds.width ?? 50) / 10
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                Text("\(nickName)さん")
                
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
                        .foregroundStyle(Color.black)
                        .frame(width: 30, height: 30)
                }
                
                Spacer()
                StrokeButton(text: "フォロー", size: .small) {
                    print("フォロー")
                }
            }
            
            // 写真のURL
            let imageURL = URL(string: postData.postImageURL ?? "")
            
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } placeholder: {
                ProgressView()
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            // タイトル、コメントへの遷移ボタン、ハート
            HStack(alignment: .top, spacing: 20) {
                Text(postData.title)
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
                    
                    Text(String(postData.likeCount))
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
                                    // ライクカウントダウン
                                } else {
                                    // ライクカウントアップ
                                }
                            }
                        }
                    
                    Text(String(postData.likeCount))
                        .font(.footnote)
                }
            }
            
            if let memo = postData.memo {
                // 説明文
                DynamicHeightCommentView(message: memo, maxTextCount: maxTextCount)
            }
            
            // 区切り線
            Divider()
        }
        // TODO: onApperをコメントアウトしないとクラッシュする
//        .onAppear {
//            Task {
//                if let userData = await cockCardVM.fetchUserData(uid: postData.uid) {
//                    DispatchQueue.main.async {
//                        // ニックネーム取得
//                        nickName = userData.nickName
//                        // アイコンURL取得
//                        iconImageURL = URL(string: userData.iconURL ?? "")
//                    }
//                }
//            }
//        }
    }
}

#Preview {
    struct PreviewView: View {
        @State private var path: [CockPostViewPath] = []
        
        let postData: PostElement = PostElement(uid: "",postImageURL: "https://firebasestorage.googleapis.com/v0/b/cockdive.appspot.com/o/postImages%2FrLVTWM5C7BiV3XbJP57G%2Fpost.jpg?alt=media&token=d4879cc3-0022-4afb-9cea-b1fe4afc19ec", title: "定食", memo: """
ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入
""", isPrivate: false, createAt: Date(), likeCount: 555, likedUser: [], comment: [])
        
        var body: some View {
            CockCardView(postData: postData, path: $path)
        }
    }
    return PreviewView()
}
