import SwiftUI

struct ProfileHeaderView: View {
    @Binding var showUser: UserElement
    @Binding var showUserFriends: UserFriendElement
    @Binding var showUserPosts: UserPostElement

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
        VStack {
            HStack {
                ImageView(
                    data: showUser.iconImage,
                    urlString: showUser.iconURL,
                    imageType: .icon
                )
                .frame(width: screenWidth / 4, height: screenWidth / 4)
                .clipShape(Circle())

                Spacer()
                HStack(spacing: 5) {
                    VStack(alignment: .center) {
                        Text("\(showUserPosts.postCount)")
                            .fontWeight(.semibold)
                        Text("投稿")
                            .font(.callout)
                    }
                    .frame(width: screenWidth/7)

                    VStack(alignment: .center) {
                        Text("\(showUserFriends.followCount)")
                            .fontWeight(.semibold)
                        Text("フォロー")
                            .font(.callout)
                    }
                    .frame(width: screenWidth/5)

                    VStack(alignment: .center) {
                        Text("\(showUserFriends.followerCount)")
                            .fontWeight(.semibold)
                        Text("フォロワー")
                            .font(.callout)
                    }
                    .frame(width: screenWidth/5)
                }
                .padding(.horizontal)
            }

            if let introduction = showUser.introduction {
                DynamicHeightCommentView(
                    message: introduction,
                    maxTextCount: 30
                )
            }
        }
        .padding()
    }
}

struct HeaderView_Previews: PreviewProvider {
    @State static var user = UserElement(nickName: "ニックネーム")
    @State static var postCount = 10
    @State static var friendData = UserFriendElement(followCount: 10, follow: [], followerCount: 10, follower: [], block: [], blockedByFriend: [])
    @State static var userPost = UserPostElement(postCount: 5, posts: [], likePostCount: 10, likePost: [])
    static var previews: some View {
        ProfileHeaderView(
            showUser: $user,
            showUserFriends: $friendData,
            showUserPosts: $userPost
        )
            .previewLayout(.sizeThatFits)
    }
}
