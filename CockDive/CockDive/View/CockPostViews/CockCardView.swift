import SwiftUI

struct CockCardView: View {
    @State var showPostData: PostElement
    @State var showUserData: UserElement?
    /// ニックネームとフォローボタンを表示するかどうか
    /// CockPostでは表示、Profileでは非表示
    let isShowUserNameAndFollowButton: Bool
    /// 画面遷移用
    @Binding var path: [CockCardNavigationPath]
    /// 親View
    let parendViewType: ParendViewType?
    /// 投稿を削除
    let deletePostAction: () -> Void
    /// 投稿を編集
    let editPostAction: (_ editPost: PostElement) -> Void
    @State var showIsLikePost: Bool = false

    // 自分の投稿か
    @State var isMyPost: Bool = false
    // ライクボタン無効状態
    @State private var isLikeButtonDisabled: Bool = false
    // フォローボタン無効状態
    @State private var isFollowButtonDisabled: Bool = false
    // 通報理由
    @State private var reportReason: String = ""
    // アラートの種類
    @State private var alertType: AlertType = .report
    // 通報アラートの表示
    @State private var showReportAlert: Bool = false

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

    enum AlertType: Identifiable {
        case noPost
        case report

        var id: AlertType { self }

        var title: String {
            switch self {
                case .noPost:
                    return "投稿が存在しません"
                case .report:
                    return "通報"
            }
        }

        var message: String {
            switch self {
                case .noPost:
                    return ""
                case .report:
                    return "通報理由を書いていただくと\n助かります。。。"
            }
        }
    }

    var body: some View {
        // 写真、タイトル、メモ、コメント、ハート
        ZStack {
            // Postの写真
            Button {
                let isFollow = cockCardVM.checkIsFollow(friendUid: showUserData?.id)
                Task {
                    // 投稿が存在する場合のみ遷移
                    if await cockCardVM.checkPostExists(postId: showPostData.id ?? "") {
                        path.append(
                            .detailView(
                                postData: showPostData,
                                userData: showUserData,
                                firstLike: showIsLikePost,
                                firstFollow: isFollow,
                                parentViewType: parendViewType
                            )
                        )
                    } else {
                        showReportAlert = true
                        alertType = .noPost
                    }
                }
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
                    HStack(alignment: .top) {
                        Button {
                            let isFollow = cockCardVM.checkIsFollow(friendUid: showUserData?.id)
                            guard let userData = showUserData else { return }
                            guard let introduction = userData.introduction else { return }
                            path.append(
                                .profileView(
                                    userData: UserElement(
                                        id: showPostData.uid,
                                        nickName: userData.nickName,
                                        introduction: introduction,
                                        iconImage: userData.iconImage,
                                        iconURL: userData.iconURL
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

                            VStack(alignment: .leading, spacing: 3) {
                                // ニックネーム
                                Text("\(showUserData?.nickName.limitTextLength(maxLength: 8) ?? "なまえ")")
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

                        // 投稿オプション
                        OptionsView(
                            isMyData: isMyPost,
                            isAlwaysWhite: true,
                            isSmall: true,
                            optionType: .post,
                            blockAction: {
                                Task {
                                    if let friend = showUserData,
                                       let friendUid = friend.id {
                                        await cockCardVM.blockUser(friendUid: friendUid)
                                    }
                                }
                            },
                            reportAction: {
                                showReportAlert = true
                                alertType = .report
                            },
                            editAction: {
                                editPostAction(showPostData)
                            },
                            deleteAction: {
                                deletePostAction()
                            }
                        )
                        .padding(.horizontal, 3)
                    }
                    .padding(.horizontal, 3)
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
                        likeCount: $showPostData.likeCount,
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
                .padding(.horizontal, 3)
            }
            .padding(3)
            .frame(width: cardWidth, height: cardHeight)
        }
        .frame(width: cardWidth, height: cardHeight)
        .alert(alertType.title, isPresented: $showReportAlert) {
            switch alertType {
            case .noPost:
                Button("OK", role: .cancel) {}
            case .report:
                TextField("通報理由", text: $reportReason)
                Button("キャンセル", role: .cancel) {}
                Button("通報", role: .destructive) {
                    Task {
                        await cockCardVM.reportPost(
                            post: showPostData,
                            reason: reportReason
                        )
                    }
                }
            }
        } message: {
            Text(alertType.message)
        }
        .onAppear {
            // 自分の投稿か確認
            isMyPost = cockCardVM.checkIsMyPost(uid: showPostData.uid)
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

struct CockCardView_Previews: PreviewProvider {
    static var previews: some View {
        CockCardView(
            showPostData: PostElement(uid: "dummy_uid", title: "定食定食定食定食定食定食", memo: "ここに説明文を挿入", isPrivate: false, createAt: Date(), likeCount: 22, likedUser: [], comment: []),
            showUserData: nil,
            isShowUserNameAndFollowButton: true,
            path: .constant([]),
            parendViewType: nil,
            deletePostAction: {},
            editPostAction: {editPost in }
        )
    }
}
