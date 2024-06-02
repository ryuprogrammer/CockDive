import SwiftUI

struct MyPageHeaderView: View {
    // UserDefaultsの基本データ（ニックネーム、自己紹介、アイコン）
    @Binding var showUserData: UserElementForUserDefaults
    // 投稿数
    @Binding var postCount: Int
    // UserFriendElement（フォロー、フォロワー）
    @Binding var showFriendData: UserFriendElement

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
                if let data = showUserData.iconImage,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth / 4, height: screenWidth / 4)
                        .clipShape(Circle())
                } else {
                    Image("iconSample4")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth / 4, height: screenWidth / 4)
                        .clipShape(Circle())
                }
                Spacer()
                HStack(spacing: 5) {
                    VStack(alignment: .center) {
                        Text("\(postCount)")
                            .fontWeight(.semibold)
                        Text("投稿")
                            .font(.callout)
                    }
                    .frame(width: screenWidth/7)

                    VStack(alignment: .center) {
                        Text("\(showFriendData.followCount)")
                            .fontWeight(.semibold)
                        Text("フォロー")
                            .font(.callout)
                    }
                    .frame(width: screenWidth/5)

                    VStack(alignment: .center) {
                        Text("\(showFriendData.followerCount)")
                            .fontWeight(.semibold)
                        Text("フォロワー")
                            .font(.callout)
                    }
                    .frame(width: screenWidth/5)
                }
                .padding(.horizontal)
            }
            
            if let introduction = showUserData.introduction {
                DynamicHeightCommentView(
                    message: introduction,
                    maxTextCount: 30
                )
            }
        }
        .padding()
    }
}

struct MyPageHeaderView_Previews: PreviewProvider {
    @State static var userData = UserElementForUserDefaults(nickName: "nickName", introduction: "プロフィール文章プロフィール文章プロフィール文章プロフィール文章プロフィール文章プロフィール文章プロフィール文章プロフィール文章プロフィール文章プロフィール文章プロフィール文章プロフィール文章プロフィール文章プロフィール文章", iconImage: Data())
    @State static var postCount = 10
    @State static var friendData = UserFriendElement(followCount: 10, follow: [], followerCount: 10, follower: [], block: [], blockedByFriend: [])

    static var previews: some View {
        MyPageHeaderView(showUserData: $userData, postCount: $postCount, showFriendData: $friendData)
            .previewLayout(.sizeThatFits)
    }
}
