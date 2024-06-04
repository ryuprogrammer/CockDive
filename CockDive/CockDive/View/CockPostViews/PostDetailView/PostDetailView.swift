import SwiftUI

struct PostDetailView: View {
    @State var showPostData: PostElement
    @State var showUserData: UserElement?
    // ライクの初期値
    @State var showIsLike: Bool
    // フォローの初期値
    @State var showIsFollow: Bool
    // ライクボタン無効状態
    @State private var isLikeButtonDisabled: Bool = false
    // フォローボタン無効状態
    @State private var isFollowButtonDisabled: Bool = false
    // コメントボタン無効状態
    @State private var isCommentButtonDisabled: Bool = false
    // コメント
    @State private var comment: String = ""
    @ObservedObject var postDetailVM = PostDetailViewModel()

    // 画面遷移戻る
    @Environment(\.presentationMode) var presentation
    let maxTextCount = 40
    @StateObject private var hapticsManager = HapticsManager()

    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    var screenWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.width
        }
        return 400
    }

    var body: some View {
        ZStack {
            ScrollView {
                // ボタンを有効にするために分割
                VStack {
                    ZStack {
                        // Postの写真
                        ImageView(
                            data: showPostData.postImage,
                            urlString: showPostData.postImageURL,
                            imageType: .post
                        )
                        .frame(width: screenWidth, height: screenWidth)
                        .clipShape(Rectangle())

                        VStack {
                            HStack {
                                // アイコン写真
                                ImageView(
                                    data: showUserData?.iconImage,
                                    urlString: showUserData?.iconURL,
                                    imageType: .icon
                                )
                                .frame(
                                    width: screenWidth / 10,
                                    height: screenWidth / 10
                                )
                                .clipShape(Circle())

                                VStack(alignment: .leading) {
                                    Text("\(showUserData?.nickName ?? "ニックネーム")")
                                        .foregroundStyle(Color.white)
                                        .fontWeight(.bold)
                                        .background(Color.black.opacity(0.3).blur(radius: 13))

                                    Text(showPostData.createAt.dateString())
                                        .foregroundStyle(Color.white)
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .background(Color.black.opacity(0.3).blur(radius: 13))
                                }

                                Spacer()

                                // フォローボタン
                                Button {
                                    // ボタンの無効化
                                    isFollowButtonDisabled = true
                                    // haptics
                                    hapticsManager.playHapticPattern()
                                    showIsFollow.toggle()
                                    Task {
                                        // フォローデータ更新
                                        await postDetailVM.followUser(friendUid: showPostData.uid)
                                        // フォローデータ取得
                                        postDetailVM.checkIsFollow(friendUid: showPostData.uid)
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        isFollowButtonDisabled = false
                                    }
                                } label: {
                                    StrokeButtonUI(
                                        text: showIsFollow ? "フォロー中" : "フォロー",
                                        size: .small,
                                        isFill: showIsFollow ? true : false
                                    )
                                    // 押せない時は少し白くする
                                    .foregroundStyle(Color.white.opacity(isFollowButtonDisabled ? 0.7 : 0.0))
                                }
                                .disabled(isFollowButtonDisabled)
                            }

                            Spacer()
                        }
                        .padding(5)
                        .frame(width: screenWidth, height: screenWidth)
                    }
                    .frame(width: screenWidth, height: screenWidth)
                }

                // ボタンを有効にするために分割
                HStack {
                    if let memo = showPostData.memo {
                        DynamicHeightCommentView(message: memo, maxTextCount: maxTextCount)
                    }

                    VStack {
                        // ライクボタン
                        Button {
                            // ボタンの無効化
                            isLikeButtonDisabled = true
                            // haptics
                            hapticsManager.playHapticPattern()

                            if showIsLike {
                                showPostData.likeCount -= 1
                            } else {
                                showPostData.likeCount += 1
                            }
                            showIsLike.toggle()
                            Task {
                                // ライクデータ変更（FirebaseとCoreData）
                                await postDetailVM.likePost(post: showPostData)
                                // CoreDataからライクデータ取得
                                postDetailVM.checkIsLike(postId: showPostData.id)
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isLikeButtonDisabled = false
                            }
                        } label: {
                            Image(systemName: showIsLike ? "heart.fill" : "heart")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                                .foregroundStyle(isLikeButtonDisabled ? Color.pink.opacity(0.7) : Color.pink)
                        }
                        .disabled(isLikeButtonDisabled)
                        .buttonStyle(BorderlessButtonStyle())

                        Text("\(showPostData.likeCount)")
                            .font(.footnote)
                    }
                }
                .padding(.top, 3)
                .padding(.horizontal)

                ForEach(showPostData.comment.reversed(), id: \.id) { comment in
                    VStack {
                        Divider()
                            .frame(height: 1)
                            .padding(0)

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
                    .padding(.vertical, 3)
                }
                .padding(.horizontal, 5)

                Spacer()
                    .frame(height: 400)
            }

            // コメント入力
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
                        print("こめ")
                        isCommentButtonDisabled = true
                        let uid = postDetailVM.fetchUid()
                        // 新しいコメント
                        let newComment: CommentElement = CommentElement(
                            uid: uid,
                            comment: comment,
                            createAt: Date()
                        )
                        // コメント追加
                        showPostData.comment.append(newComment)
                        comment = ""
                        // コメント保存
                        postDetailVM.updateComment(post: showPostData, newComment: newComment)
                        UIApplication.shared.keybordClose()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isCommentButtonDisabled = false
                        }
                    } label: {
                        Image(systemName: "paperplane.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 34)
                            .foregroundStyle(isCommentButtonDisabled ? Color.white.opacity(0.7) : Color.white)
                    }
                    .disabled(isCommentButtonDisabled)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(Color.mainColor)
            }
        }
        // TabBar非表示
        .toolbar(.hidden, for: .tabBar)
        // 戻るボタン非表示
        .navigationBarBackButtonHidden(true)
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
            Task {
                await postDetailVM.fetchUserData(uid: showPostData.uid)
                if let data = postDetailVM.userData {
                    showUserData = data
                }
            }
            // Postデータをリッスン
            postDetailVM.listenToPost(postId: showPostData.id)
        }
        .onChange(of: postDetailVM.postData) { newPostData in
            if let newPostData {
                // データが更新されたので、画面に描画
                showPostData = newPostData
            }
        }
        .onChange(of: postDetailVM.isLike) { isLike in
            // ライク更新
            showIsLike = isLike
        }
        .onChange(of: postDetailVM.isFollow) { isFollow in
            // フォロー更新
            showIsFollow = isFollow
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
                    ),
                    showUserData: UserElement(nickName: "ニックネーム"),
                    showIsLike: false,
                    showIsFollow: false
                )
            }
        }
    }
    return PreviewView()
}
