import SwiftUI

struct PostDetailView: View {
    @State var  postData: PostElement
    // コメント
    @State private var comment: String = ""
    let postDetailVM = PostDetailViewModel()
    // TabBar用
    @State var flag: Visibility = .hidden
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    // キーボード制御
    @FocusState private var keybordFocuse: Bool
    // 画面遷移戻る
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        let imageURL = URL(string: postData.postUserIconImageURL ?? "")
                        
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    width: (window?.screen.bounds.width ?? 50) / 12,
                                    height: (window?.screen.bounds.width ?? 50) / 10
                                )
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .foregroundStyle(Color.gray)
                                .frame(
                                    width: (window?.screen.bounds.width ?? 50) / 12,
                                    height: (window?.screen.bounds.width ?? 50) / 10
                                )
                        }
                        
                        VStack(alignment: .leading) {
                            Text("\(postData.postUserNickName ?? "ニックネーム")さん")
                            
                            Text(postData.createAt.dateString())
                                .font(.footnote)
                        }
                        
                        Spacer()
                        
                        StrokeButton(text: "フォロー", size: .small) {
                            Task {
                                await postDetailVM.followUser(friendUid: postData.uid)
                            }
                        }
                    }
                    
                    ZStack {
                        Image("cockImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    
                    Text(postData.memo ?? "")
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                
                ForEach(postData.comment, id: \.self) { comment in
                    PostCommentView(comment: comment) {
                        Task {
                            // ブロック
                            await postDetailVM.blockUser(friendUid: comment.uid)
                        }
                    } reportAction: {
                        Task {
                            // 通報
                            await postDetailVM.reportUser(friendUid: comment.uid)
                        }
                    }

                }
                .padding(.horizontal)
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
                        // コメント追加
                        
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
        .toolbarBackground(Color.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            // 戻るボタン
            ToolbarItem(placement: .topBarLeading) {
                ToolBarBackButtonView {
                    self.presentation.wrappedValue.dismiss()
                }
            }
            
            // タイトル
            ToolbarItem(placement: .principal) {
                Text(postData.title)
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .font(.title3)
            }
            
            // 通報
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await postDetailVM.reportUser(friendUid: postData.uid)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25)
                        .foregroundStyle(Color.white)
                }
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        var body: some View {
            NavigationStack {
                PostDetailView(
                    postData: PostElement(
                        id: "000",
                        uid: "mmmmmmmm",
                        postImage: Data(),
                        postImageURL: "https://firebasestorage.googleapis.com/v0/b/cockdive.appspot.com/o/postImages%2FrLVTWM5C7BiV3XbJP57G%2Fpost.jpg?alt=media&token=d4879cc3-0022-4afb-9cea-b1fe4afc19ec",
                        title: "定食",
                        memo: """
ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入
""",
                        isPrivate: false,
                        createAt: Date(),
                        likeCount: 10,
                        likedUser: [],
                        comment: [
                            CommentElement(id: UUID(), uid: "aaaa", comment: "美味しそ", createAt: Date()),
                            CommentElement(id: UUID(), uid: "aaaa", comment: "美味しそ", createAt: Date()),
                            CommentElement(id: UUID(), uid: "aaaa", comment: "美味しそ", createAt: Date())
                        ]
                    )
                )
            }
        }
    }
    return PreviewView()
}
