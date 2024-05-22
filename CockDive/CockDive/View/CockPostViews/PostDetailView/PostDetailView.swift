import SwiftUI

struct PostDetailView: View {
    @State var showPostData: PostElement
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
                        // アイコン写真
                        if let data = showPostData.postUserIconImage,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    width: (window?.screen.bounds.width ?? 50) / 12,
                                    height: (window?.screen.bounds.width ?? 50) / 10
                                )
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    width: (window?.screen.bounds.width ?? 50) / 12,
                                    height: (window?.screen.bounds.width ?? 50) / 10
                                )
                                .clipShape(Circle())
                        }

                        VStack(alignment: .leading) {
                            Text("\(showPostData.postUserNickName ?? "ニックネーム")さん")

                            Text(showPostData.createAt.dateString())
                                .font(.footnote)
                        }

                        Spacer()
                    }

                    // Postの写真
                    if let data = showPostData.postImage,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }

                    Text(showPostData.memo ?? "")
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()

                ForEach(showPostData.comment.reversed(), id: \.id) { comment in
                    Text("コメント: \(comment.comment)")
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
                .listStyle(.plain)

                Spacer()
                    .frame(height: 300)
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
//                        Task {
//                            if let userData = await postDetailVM.fetchUserData() {
//                                DispatchQueue.main.async {
//                                    print("送信ボタンタップされた")
//                                    // 新しいコメント
//                                    let newComment: CommentElement = CommentElement(
//                                        uid: userData.id ?? "",
//                                        commentUserNickName: userData.nickName,
//                                        commentUserIcon: userData.iconImage,
//                                        comment: comment,
//                                        createAt: Date()
//                                    )
//                                    // コメント追加
//                                    showPostData.comment.append(newComment)
//                                    print("showPostData.comment.count: \(showPostData.comment.count)")
//                                    self.comment = ""
//                                    // キーボード閉じる
//                                    UIApplication.shared.keybordClose()
//                                }
//
//                            }
//                        }
                        // 新しいコメント
                        let newComment: CommentElement = CommentElement(
                            uid: "id",
                            commentUserNickName: "userData.nickName",
                            commentUserIcon: nil,
                            comment: comment,
                            createAt: Date()
                        )
                        // コメント追加
                        showPostData.comment.append(newComment)
                        self.comment = ""
                        UIApplication.shared.keybordClose()
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
                Text(showPostData.title)
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .font(.title3)
            }

            // 通報
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await postDetailVM.reportUser(friendUid: showPostData.uid)
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
            print("コメント: \(showPostData.comment)")
            // Postデータをリッスン
            postDetailVM.listenToPost(postId: showPostData.id)
        }
        .onChange(of: postDetailVM.postData) { newPostData in
            if let newPostData {
                // データが更新されたので、画面に描画
                showPostData = newPostData
            }
        }
        .onChange(of: $showPostData.comment.count) {_ in
            /// 表示しているコメントとPostDataのコメントが異なる場合のみコメントを更新
            /// コメントの追加、削除を一括で行う。
            /// 画面更新するのは一瞬で行いたいため。
            postDetailVM.updateComment(post: showPostData, comments: showPostData.comment)
        }
    }
}

#Preview {
    struct PreviewView: View {
        var body: some View {
            NavigationStack {
                PostDetailView(
                    showPostData: PostElement(
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
