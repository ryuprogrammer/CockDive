import SwiftUI

struct CockCardView: View {
    @State var showPostData: PostElement
    @State var showUserData: UserElement?
    @State var showIsLikePost: Bool = false

    @Binding var path: [CockCardNavigationPath]
    /// ニックネームとフォローボタンを表示するかどうか
    /// CockPostでは表示、Profileでは非表示
    let isShowUserNameAndFollowButton: Bool
    // ライクボタン無効状態
    @State private var isLikeButtonDisabled: Bool = false
    // フォローボタン無効状態
    @State private var isFollowButtonDisabled: Bool = false

    let maxTextCount = 20
    @ObservedObject private var cockCardVM = CockCardViewModel()
    @State private var isLineLimit: Bool = false
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    var cardWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return (screen.bounds.width) / 2 - 2
        }
        return 400
    }

    var cardHeight: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return (screen.bounds.width) / 2 - 2
        }
        return 800
    }

    @StateObject private var hapticsManager = HapticsManager()

    var body: some View {
        // 写真、タイトル、メモ、コメント、ハート
        ZStack {
            // Postの写真
            Button {
                let isFollow = cockCardVM.checkIsFollow(friendUid: showUserData?.id)
                path.append(
                    .detailView(
                        postData: showPostData,
                        userData: showUserData,
                        firstLike: showIsLikePost,
                        firstFollow: isFollow
                    )
                )
            } label: {
                // Postの写真
                ImageView(
                    data: showPostData.postImage,
                    urlString: showPostData.postImageURL,
                    imageType: .post
                )
                .frame(width: cardWidth, height: cardWidth)
                .clipShape(Rectangle())
            }

            VStack {
                // アイコン、ニックネーム
                if isShowUserNameAndFollowButton {
                    HStack {
                        Button {
                            let isFollow = cockCardVM.checkIsFollow(friendUid: showUserData?.id)
                            path.append(
                                .profileView(
                                    userData: UserElement(
                                        id: showPostData.uid,
                                        nickName: showUserData?.nickName ?? "",
                                        introduction: nil,
                                        iconURL: showUserData?.iconURL
                                    ),
                                    showIsFollow: isFollow
                                )
                            )
                        } label: {
                            // アイコン写真
                            ImageView(
                                data: showUserData?.iconImage,
                                urlString: showUserData?.iconURL,
                                imageType: .icon
                            )
                            .frame(width: cardWidth / 6, height: cardWidth / 6)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 3) { // 隙間を3に設定
                                // ニックネーム
                                Text("\(showUserData?.nickName.limitTextLength(maxLength: 8) ?? "ニックネーム")")
                                    .foregroundStyle(Color.white)
                                    .font(.subheadline)
                                    .fontWeight(.bold)

                                Text("\(showPostData.createAt.dateString())")
                                    .foregroundStyle(Color.white)
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                        }
                        .background(
                            Color.black
                                .opacity(0.3)
                                .blur(radius: 15)
                        )

                        Spacer()
                    }
                    .padding(.horizontal, 3) // 隙間を3に設定
                    .frame(width: cardWidth)
                }

                Spacer()

                HStack(alignment: .bottom) {
                    // タイトル
                    Text(showPostData.title.limitTextLength(maxLength: 9))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .background(
                            Color.black
                                .opacity(0.3)
                                .blur(radius: 15)
                        )

                    Spacer()

                    // ライクボタン
                    LikeButtonView(
                        isLiked: $showIsLikePost,
                        isButtonDisabled: $isLikeButtonDisabled,
                        buttonSize: CGSize(width: cardWidth/8, height: cardWidth/8)
                    ) {
                        // ボタンの無効化
                        isLikeButtonDisabled = true
                        // haptics
                        hapticsManager.playHapticPattern()

                        if showIsLikePost {
                            showPostData.likeCount -= 1
                        } else {
                            showPostData.likeCount += 1
                        }
                        showIsLikePost.toggle()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLikeButtonDisabled = false
                        }
                    }
                    .background(
                        Color.black
                            .opacity(0.3)
                            .blur(radius: 15)
                    )
                }
                .padding(.horizontal, 3) // 隙間を3に設定
            }
            .padding(3) // 隙間を3に設定
            .frame(width: cardWidth, height: cardHeight)
        }
        .frame(width: cardWidth, height: cardHeight)
        .onAppear {
            Task {
                await cockCardVM.fetchUserData(uid: showPostData.uid)
                showUserData = cockCardVM.userData
            }
            // データの初期化
            cockCardVM.postData = showPostData
            // ライクを初期化
            showIsLikePost = cockCardVM.checkIsLike(postId: showPostData.id)
            // データのリッスン開始
            if let id = showPostData.id {
                cockCardVM.listenToPost(postId: id)
            }
        }
        .onChange(of: cockCardVM.postData) { newPostData in
            if let postData = newPostData {
                // 画面のpostを更新
                showPostData = postData
            }
        }
        .onChange(of: showIsLikePost) { newLike in
            Task {
                // ライクデータ変更（FirebaseとCoreData）
                await cockCardVM.likePost(post: showPostData, toLike: newLike)
            }
        }
        .onDisappear {
            cockCardVM.stopListeningToPosts()
        }
    }
}

#Preview {
    struct PreviewView: View {
        let postData: PostElement = PostElement(uid: "dummy_uid", title: "定食定食定食定食定食定食", memo: "ここに説明文を挿入", isPrivate: false, createAt: Date(), likeCount: 22, likedUser: [], comment: [])

        @State var path: [CockCardNavigationPath] = []
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 3) { // 隙間を3に設定
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                }
            }
            .padding(.horizontal, 3) // 隙間を3に設定
        }
    }
    return PreviewView()
}


// メッセージ
//VStack(spacing: 1) {
//    Image(systemName: "message")
//        .resizable()
//        .aspectRatio(contentMode: .fit)
//        .frame(width: 30)
//        .foregroundStyle(Color.black)
//
//    Text(String(showPostData.comment.count))
//        .font(.footnote)
//}
