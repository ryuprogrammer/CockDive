import SwiftUI

struct PostDetailView: View {
    @State var showPostData: PostElement
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
    let postDetailVM = PostDetailViewModel()
    // TabBar用
    @State var flag: Visibility = .hidden
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    // 画面遷移戻る
    @Environment(\.presentationMode) var presentation
    let maxTextCount = 40
    @StateObject private var hapticsManager = HapticsManager()

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

                        // フォローボタン
                        Button {
                            // ボタンの無効化
                            isFollowButtonDisabled = true
                            // haptics
                            hapticsManager.playHapticPattern()
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
                        .buttonStyle(BorderlessButtonStyle())
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

                    HStack {
                        if let memo = showPostData.memo {
                            DynamicHeightCommentView(message: memo, maxTextCount: maxTextCount)
                        }

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
                    }
                    .padding(.top)
                }
                .padding()

                ForEach(showPostData.comment.reversed(), id: \.id) { comment in
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
                    .padding(.horizontal)
                    .padding(.vertical, 3)
                }
                .listStyle(.plain)

                Spacer()
                    .frame(height: 300)
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
                        // userData取得
                        guard let userData = postDetailVM.fetchUserData() else { return }
                        let uid = postDetailVM.fetchUid()
                        // 新しいコメント
                        let newComment: CommentElement = CommentElement(
                            uid: uid,
                            commentUserNickName: userData.nickName,
                            commentUserIcon: userData.iconImage,
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
                    ),
                    showIsLike: false,
                    showIsFollow: false
                )
            }
        }
    }
    return PreviewView()
}
