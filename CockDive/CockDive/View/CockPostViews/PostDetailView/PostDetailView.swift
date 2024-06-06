import SwiftUI

struct PostDetailView: View {
    @State var showPostData: PostElement
    @State var showUserData: UserElement?
    // ライクの初期値
    @State var showIsLike: Bool
    // フォローの初期値
    @State var showIsFollow: Bool
    // 画面遷移
    @Binding var cockCardNavigationPath: [CockCardNavigationPath]
    // 親ViewのPostsData→Detailで削除したときに、親Viewでも削除する
    @Binding var parentViewPosts: [PostElement]
    // 自分の投稿か
    @State var isMyPost: Bool = false
    // ライクボタン無効状態
    @State private var isLikeButtonDisabled: Bool = false
    // フォローボタン無効状態
    @State private var isFollowButtonDisabled: Bool = false
    // コメントボタン無効状態
    @State private var isCommentButtonDisabled: Bool = false
    // コメント
    @State private var comment: String = ""
    @ObservedObject var postDetailVM = PostDetailViewModel()
    // 通報理由
    @State private var reportReason: String = ""
    // 通報アラートの表示
    @State private var showReportAlert: Bool = false
    // アラートの情報
    @State private var alertType: AlertType = .post
    // キーボードフォーカス
    @FocusState private var keyboardFocus: Bool

    // アラートタイプ
    private enum AlertType {
        case user(uid: String)
        case post
    }
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

                            HStack {
                                Spacer()

                                Text("\(showPostData.likeCount)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.white)

                                // ライクボタン
                                LikeButtonView(
                                    isLiked: $showIsLike,
                                    isButtonDisabled: $isLikeButtonDisabled,
                                    buttonSize: CGSize(width: screenWidth/12, height: screenWidth/12)
                                ) {
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

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        isLikeButtonDisabled = false
                                    }
                                }
                            }
                        }
                        .padding(5)
                        .frame(width: screenWidth, height: screenWidth)
                    }
                    .frame(width: screenWidth, height: screenWidth)
                }

                if let memo = showPostData.memo {
                    DynamicHeightCommentView(message: memo)
                        .padding(.top, 3)
                        .padding(.horizontal)
                }

                ForEach(showPostData.comment.reversed(), id: \.id) { comment in
                    VStack {
                        Divider()
                            .frame(height: 1)
                            .padding(0)

                        PostCommentView(
                            comment: comment,
                            isMyComment: postDetailVM.checkIsMyPost(uid: comment.uid),
                            blockAction: {
                                Task {
                                    // ブロック
                                    await postDetailVM.blockUser(friendUid: comment.uid)
                                }
                            },
                            reportAction: {
                                // ここでアラート表示
                                showReportAlert = true
                                alertType = .user(uid: comment.uid)
                            },
                            deleteAction: {
                                // コメント削除→自分のコメントのみ削除
                                postDetailVM.deleteComment(
                                    post: showPostData,
                                    commentToDelete: comment
                                )
                            }
                        )
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
                    .focused($keyboardFocus)

                    Button {
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
        .contentShape(Rectangle())
        .onTapGesture {
            keyboardFocus = false
        }
        .alert("通報", isPresented: $showReportAlert) {
            TextField("通報理由を入力してください", text: $reportReason)
            Button("キャンセル", role: .cancel) {}
            Button("通報", role: .destructive) {
                switch alertType {
                case .user(let uid):
                    Task {
                        await postDetailVM.reportUser(
                            reportedUid: uid,
                            post: showPostData,
                            reason: reportReason
                        )
                    }
                case .post:
                    Task {
                        await postDetailVM.reportPost(
                            post: showPostData,
                            reason: reportReason
                        )
                    }
                }
            }
        } message: {
            Text("通報理由を書いていただくと\n助かります。。。")
        }
        // TabBar非表示
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle(showPostData.title)
        .toolbarColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                OptionsView(
                    isMyData: isMyPost,
                    isAlwaysWhite: true,
                    isSmall: false,
                    optionType: .post,
                    blockAction: {
                        Task {
                            // ブロック
                            await postDetailVM.blockUser(friendUid: showPostData.uid)
                        }
                    },
                    reportAction: {
                        // 通報のアラート表示
                        showReportAlert = true
                    },
                    editAction: {},
                    deleteAction: {
                        if showPostData.uid == postDetailVM.fetchUid() {
                            Task {
                                // 投稿削除
                                await postDetailVM.deletePost(postId: showPostData.id)
                                // 親Viewの該当する投稿も削除
                                parentViewPosts.removeAll(where: {$0.id == showPostData.id})
                                // 画面遷移
                                cockCardNavigationPath.removeLast()
                            }
                        }
                    }
                )
            }
        }
        .onAppear {
            // 自分の投稿か確認
            isMyPost = postDetailVM.checkIsMyPost(uid: showPostData.uid)
            Task {
                await postDetailVM.fetchUserData(uid: showPostData.uid)
                if let data = postDetailVM.userData {
                    showUserData = data
                }
            }

            if let postId = showPostData.id {
                // Postデータをリッスン
                postDetailVM.listenToPost(postId: postId)
            }
        }
        .onChange(of: postDetailVM.postData) { newPostData in
            if let newPostData {
                // データが更新されたので、画面に描画
                showPostData = newPostData
            }
        }
        .onChange(of: showIsLike) { newLike in
            Task {
                // ライクデータ変更（FirebaseとCoreData）
                await postDetailVM.likePost(
                    post: showPostData,
                    toLike: newLike
                )
            }
        }
        .onChange(of: showIsFollow) { newFollow in
            Task {
                // フォローデータ更新
                await postDetailVM.followUser(friendUid: showPostData.uid)
                // フォローデータ取得
                postDetailVM.checkIsFollow(friendUid: showPostData.uid)
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        var body: some View {
            NavigationStack {
                PostDetailView(
                    showPostData: PostElement(
                        id: nil,
                        uid: "0000000",
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
                    showUserData: nil,
                    showIsLike: false,
                    showIsFollow: false,
                    cockCardNavigationPath: .constant([]),
                    parentViewPosts: .constant([])
                )
            }
        }
    }
    return PreviewView()
}
