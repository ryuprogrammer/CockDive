import SwiftUI

struct CockCardView: View {
    @State var showPostData: PostElement
    @State var showUserData: UserElement?
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
            return screen.bounds.width / 2 - 3
        }
        return 400
    }

    var cardHeight: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.height / 4
        }
        return 800
    }

    @StateObject private var hapticsManager = HapticsManager()

    var body: some View {
        VStack(spacing: 0) {
            // 写真、タイトル、メモ、コメント、ハート
            ZStack {
                // Postの写真
                Button {
                    path.append(
                        .detailView(
                            postData: showPostData,
                            userData: showUserData,
                            firstLike: cockCardVM.showIsLikePost,
                            firstFollow: cockCardVM.showIsFollow
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
                        Button {
                            let isFollow = cockCardVM.showIsFollow
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
                            HStack {
                                HStack {
                                    // アイコン写真
                                    ImageView(
                                        data: showUserData?.iconImage,
                                        urlString: showUserData?.iconURL,
                                        imageType: .icon
                                    )
                                    .frame(width: cardWidth / 6, height: cardWidth / 6)
                                    .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 0) {
                                        // ニックネーム
                                        Text("\(showUserData?.nickName.limitTextLength(maxLength: 8) ?? "ニックネーム")")
                                            .foregroundStyle(Color.white)
                                            .font(.headline)
                                            .fontWeight(.bold)

                                        Text("\(showPostData.createAt.dateString())")
                                            .foregroundStyle(Color.white)
                                            .font(.caption)
                                    }
                                }
                                .background(
                                    Color.black
                                        .opacity(0.3)
                                        .blur(radius: 10)
                                )


                                Spacer()
                            }
                            .padding(3)
                            .frame(width: cardWidth)
                        }
                    }

                    Spacer()

                    HStack(alignment: .bottom) {
                        Text(showPostData.title.limitTextLength(maxLength: 8))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .padding(3)
                            .background(
                                Color.black
                                    .opacity(0.35)
                                    .blur(radius: 10)
                            )

                        Spacer()

                        // ライクボタン
                        Button {
                            // ボタンの無効化
                            isLikeButtonDisabled = true
                            // haptics
                            hapticsManager.playHapticPattern()

                            if cockCardVM.showIsLikePost {
                                showPostData.likeCount -= 1
                            } else {
                                showPostData.likeCount += 1
                            }
                            Task {
                                // ライクデータ変更（FirebaseとCoreData）
                                await cockCardVM.likePost(post: showPostData)
                                // CoreDataからライクデータ取得
                                cockCardVM.checkIsLike(postId: showPostData.id)
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isLikeButtonDisabled = false
                            }
                        } label: {
                            Image(systemName: cockCardVM.showIsLikePost ? "heart.fill" : "heart")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: cardWidth/8)
                                .padding([.top, .leading], 5)
                                .foregroundStyle(cockCardVM.showIsLikePost ? Color.pink : Color.white)
                        }
                        .disabled(isLikeButtonDisabled)
                        .padding(5)
                        .background(Color.black.opacity(0.5).blur(radius: 10))
                    }
                }
                .frame(width: cardWidth, height: cardWidth)
                .clipShape(Rectangle())
            }
        }
        .frame(width: cardWidth)
        .onAppear {
            Task {
                await cockCardVM.fetchUserData(uid: showPostData.uid)
                showUserData = cockCardVM.userData
            }
            // データの初期化
            cockCardVM.postData = showPostData
            // フォローとライクを初期化
            cockCardVM.checkIsLike(postId: showPostData.id)
            cockCardVM.checkIsFollow(friendUid: showPostData.uid)
        }
        .onChange(of: cockCardVM.postData) { newPostData in
            if let postData = newPostData {
                // 画面のpostを更新
                showPostData = postData
            }
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
                LazyVGrid(columns: columns, spacing: 3) {
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                    CockCardView(showPostData: postData, path: $path, isShowUserNameAndFollowButton: true)
                }
            }
            .padding(.horizontal, 3)
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
