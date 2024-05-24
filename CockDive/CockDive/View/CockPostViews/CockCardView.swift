import SwiftUI

struct CockCardView: View {
    @State var showPostData: PostElement
    // ライクボタン無効状態
    @State private var isLikeButtonDisabled: Bool = false
    // フォローボタン無効状態
    @State private var isFollowButtonDisabled: Bool = false

    let maxTextCount = 20
    @ObservedObject private var cockCardVM = CockCardViewModel()
    @State private var isLineLimit: Bool = false
    var screenWidth: CGFloat {
#if DEBUG
        return UIScreen.main.bounds.width
#else
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first?.screen.bounds.width ?? 50
#endif
    }

    @Binding var path: [CockCardNavigationPath]
    @StateObject private var hapticsManager = HapticsManager()

    var body: some View {
        // アイコン、ニックネーム、フォローボタン、区切り線のセクション
        VStack {
            HStack {
                Button {
                    path.append(
                        .profileView(
                            userData: UserElement(
                                id: showPostData.uid,
                                nickName: showPostData.postUserNickName ?? "",
                                introduction: nil,
                                iconImage: showPostData.postUserIconImage,
                                iconURL: nil
                            )
                        )
                    )
                } label: {
                    HStack {
                        // アイコン画像
                        if let data = showPostData.postUserIconImage,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color.gray)
                                .frame(width: screenWidth / 12, height: screenWidth / 12)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color.gray)
                                .frame(width: screenWidth / 12, height: screenWidth / 12)
                        }

                        // ニックネーム
                        Text("\(showPostData.postUserNickName ?? "ニックネーム")さん")
                            .foregroundStyle(Color.black)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())

                Menu {
                    Button(action: {
                        Task {
                            /// ブロックするアクション
                            if let uid = cockCardVM.postData?.uid {
                                await cockCardVM.blockUser(friendUid: uid)
                            }
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "nosign")
                            Spacer()
                            Text("ブロック")
                        }
                    })

                    Button(action: {
                        /// 通報するアクション
                        if let uid = cockCardVM.postData?.uid {
                            cockCardVM.reportUser(friendUid: uid)
                        }
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

                // フォローボタン
                Button {
                    Task {
                        // フォローデータ更新
                        await cockCardVM.followUser(friendUid: showPostData.uid)
                        // フォローデータ取得
                        cockCardVM.checkIsFollow(friendUid: showPostData.uid)
                    }
                    print("cockCardVM.showIsFollow: \(cockCardVM.showIsFollow)")
                    isFollowButtonDisabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isFollowButtonDisabled = false
                        print("押せるよ！")
                    }
                } label: {
                    StrokeButtonUI(
                        text: cockCardVM.showIsFollow ? "フォロー中" : "フォロー" ,
                        size: .small,
                        isFill: cockCardVM.showIsFollow ? true : false
                    )
                    .overlay {
                        // 押せない時は少し白くする
                        Color.white.opacity(isFollowButtonDisabled ? 0.7 : 0.0)
                    }
                }
                .disabled(isFollowButtonDisabled)
                .buttonStyle(BorderlessButtonStyle())
            }
        }

        // 写真、タイトル、メモ、コメント、ハート
        VStack {
            // Postの写真
            if let data = showPostData.postImage,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                Image(systemName: "birthday.cake")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }

            HStack(alignment: .top, spacing: 15) {
                Text(showPostData.title)
                    .font(.title)

                Spacer()

                VStack(spacing: 1) {
                    Image(systemName: "message")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundStyle(Color.black)

                    Text(String(showPostData.comment.count))
                        .font(.footnote)
                }

                VStack(spacing: 1) {
                    // ライクボタン
                    Button {
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
                        print("cockCardVM.showIsLikePost: \(cockCardVM.showIsLikePost)")
                        isLikeButtonDisabled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLikeButtonDisabled = false
                        }

                    } label: {
                        Image(systemName: cockCardVM.showIsLikePost ? "heart.fill" : "heart")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .foregroundStyle(isLikeButtonDisabled ? Color.pink.opacity(0.7) : Color.pink)
                    }
                    .disabled(isLikeButtonDisabled)
                    .buttonStyle(BorderlessButtonStyle())

                    Text(String(showPostData.likeCount))
                        .font(.footnote)
                }
            }

            if let memo = showPostData.memo {
                DynamicHeightCommentView(message: memo, maxTextCount: maxTextCount)
            }

            Divider()
                .frame(height: 1)
                .padding(0)
        }
        .onAppear {
            // データの初期化
            cockCardVM.postData = showPostData
            if let id = showPostData.id {
                // Postデータをリッスン開始
                cockCardVM.listenToPost(postId: id)
            }
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

        let postData: PostElement = PostElement(uid: "dummy_uid", postImageURL: "https://example.com/image.jpg", title: "定食", memo: "ここに説明文を挿入", isPrivate: false, createAt: Date(), likeCount: 555, likedUser: [], comment: [])

        @State var path: [CockCardNavigationPath] = []
        var body: some View {
            List {
                CockCardView(showPostData: postData, path: $path)
                    .listRowSeparator(.hidden)

                CockCardView(showPostData: postData, path: $path)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }
    return PreviewView()
}
