import SwiftUI

struct PostDetailView: View {
    let postData: PostElement
    // 画面表示用のPostData
    @State private var showPostData: PostElement = PostElement(uid: "", title: "", isPrivate: true, createAt: Date(), likeCount: 0, likedUser: [], comment: [])
    // コメント
    @State private var comment: String = ""
    let postDetailVM = PostDetailViewModel()
    // TabBar用
    @State var flag: Visibility = .hidden
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    // 画面遷移戻る
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        let imageURL = URL(string: showPostData.postUserIconImageURL ?? "")
                        
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
                        let postImageURL = URL(string: showPostData.postImageURL ?? "")
                        
                        AsyncImage(url: postImageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    
                    Text(showPostData.memo ?? "")
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                
                ForEach(showPostData.comment, id: \.id) { comment in
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
                    
                    Button {
                        Task {
                            if let userData = await postDetailVM.fetchUserData() {
                                // 新しいコメント
                                let newComment: CommentElement = CommentElement(
                                    uid: userData.id ?? "",
                                    commentUserNickName: userData.nickName,
                                    commentUserIconURL: userData.iconURL,
                                    comment: comment,
                                    createAt: Date()
                                )
                                // コメント追加
                                showPostData.comment.append(newComment)
                                self.comment = ""
                                // キーボード閉じる
                                UIApplication.shared.keybordClose()
                            }
                        }
                    } label: {
                        Image(systemName: "paperplane.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 34)
                            .foregroundStyle(Color.white)
                    }
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
        .onAppear {
            /// 画面を最速で描画したい
            /// 親画面からPostDataを取得
            showPostData = postData
            /// 最新のPostDataを取得
            Task {
                if let postData = await postDetailVM.fetchPostFromPostId(postId: postData.id ?? "") {
                    showPostData = postData
                }
            }
            
        }
        .onChange(of: $showPostData.comment.count) {_ in
            /// 表示しているコメントとPostDataのコメントが異なる場合のみコメントを更新
            /// コメントの追加、削除を一括で行う。
            /// 画面更新するのは一瞬で行いたいため。
            postDetailVM.updateComment(post: postData, comments: showPostData.comment)
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
