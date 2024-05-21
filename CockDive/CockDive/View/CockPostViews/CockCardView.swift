import SwiftUI

struct CockCardView: View {
    let postData: PostElement
    let friendData: UserFriendElement?
    // 画面表示用のフォロープロパティ
    @State private var showIsFollow: Bool = false
    // 画面表示用のライクプロパティ
    @State private var showIsLike: Bool = false
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
    
    var body: some View {
        VStack {
            HStack {
                // アイコン画像
                if let data = cockCardVM.showPostData?.postUserIconImage,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.gray)
                        .frame(width: screenWidth / 10, height: screenWidth / 10)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.gray)
                        .frame(width: screenWidth / 10, height: screenWidth / 10)
                }
                
                Text("\(cockCardVM.showPostData?.postUserNickName ?? "ニックネーム")さん")
                
                Menu {
                    Button(action: {
                        Task {
                            /// ブロックするアクション
                            if let uid = cockCardVM.showPostData?.uid {
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
                        if let uid = cockCardVM.showPostData?.uid {
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
                    if isFollowButtonDisabled {
                        return
                    }
                    
                    showIsFollow.toggle()
                    
                    Task {
                        if let uid = cockCardVM.showPostData?.uid {
                            await cockCardVM.followUser(friendUid: uid)
                        }
                    }
                    
                    isFollowButtonDisabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isFollowButtonDisabled = false
                    }
                } label: {
                    StrokeButtonUI(text: showIsFollow ? "フォロー中" : "フォロー" , size: .small, isFill: showIsFollow ? true : false)
                }
                .disabled(isFollowButtonDisabled)
            }
            
            // 写真
            if let data = cockCardVM.showPostData?.postImage,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                Image(systemName: "birthday.cake")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            HStack(alignment: .top, spacing: 20) {
                Text(cockCardVM.showPostData?.title ?? "")
                    .font(.title)
                
                Spacer()
                
                VStack(spacing: 1) {
                    Image(systemName: "message")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundStyle(Color.black)
                        .onTapGesture {
                            if let postData = cockCardVM.showPostData {
                                path.append(.detailView(postData: postData))
                            }
                        }
                    
                    Text(String(cockCardVM.showPostData?.comment.count ?? 0))
                        .font(.footnote)
                }
                
                VStack(spacing: 1) {
                    // ライクボタン
                    Image(systemName: showIsLike ? "heart.fill" : "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundStyle(isLikeButtonDisabled ? Color.pink.opacity(0.7) : Color.pink)
                        .onTapGesture {
                            if isLikeButtonDisabled {
                                return
                            }
                            
                            if showIsLike {
                                cockCardVM.showPostData?.likeCount -= 1
                                showIsLike = false
                            } else {
                                cockCardVM.showPostData?.likeCount += 1
                                showIsLike = true
                            }
                            
                            Task {
                                if let postData = cockCardVM.showPostData {
                                    await cockCardVM.likePost(post: postData)
                                }
                            }
                            
                            isLikeButtonDisabled = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isLikeButtonDisabled = false
                            }
                        }
                    
                    Text(String(cockCardVM.showPostData?.likeCount ?? 0))
                        .font(.footnote)
                }
            }
            
            if let memo = cockCardVM.showPostData?.memo {
                DynamicHeightCommentView(message: memo, maxTextCount: maxTextCount)
            }
            
            Divider()
        }
        .onAppear {
            // データの初期化
            cockCardVM.showPostData = postData
            if let id = postData.id {
                // Postデータをリッスン開始
                cockCardVM.listenToPost(postId: id)
            }
        }
        .onChange(of: cockCardVM.showPostData) { newPostData in
            // フォローとライクを更新
            if let postData = newPostData {
                showIsFollow = cockCardVM.checkIsFollow(userFriendData: friendData, friendUid: postData.uid)
                showIsLike = cockCardVM.checkIsLike(postData: postData)
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        
        let postData: PostElement = PostElement(uid: "dummy_uid", postImageURL: "https://example.com/image.jpg", title: "定食", memo: "ここに説明文を挿入", isPrivate: false, createAt: Date(), likeCount: 555, likedUser: [], comment: [])
        let userFriendData: UserFriendElement = UserFriendElement(
            followCount: 1,
            follow: [],
            followerCount: 1,
            follower: [],
            block: [],
            blockedByFriend: []
        )
        @State var path: [CockCardNavigationPath] = []
        var body: some View {
            CockCardView(postData: postData, friendData: userFriendData, path: $path)
        }
    }
    return PreviewView()
}
