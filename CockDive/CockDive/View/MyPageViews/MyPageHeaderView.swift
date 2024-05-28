import SwiftUI

struct MyPageHeaderView: View {
    // UserDefaultsの基本データ（ニックネーム、自己紹介、アイコン）
    @Binding var showUserData: UserElementForUserDefaults
    // 投稿数
    @Binding var postCount: Int
    // UserFriendElement（フォロー、フォロワー）
    @Binding var showFriendData: UserFriendElement
    // 画面サイズ取得
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    var screenWidth: CGFloat {
        windowScene?.screen.bounds.width ?? 0
    }

    var body: some View {
        VStack {
            HStack {
                if let data = showUserData.iconImage,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.gray)
                        .frame(width: screenWidth / 6, height: screenWidth / 6)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.gray)
                        .frame(width: screenWidth / 6, height: screenWidth / 6)
                }
                Spacer()
                HStack(spacing: 15) {
                    VStack {
                        Text("\(postCount)")
                        Text("投稿")
                    }
                    VStack {
                        Text("\(showFriendData.followCount)")
                        Text("フォロー")
                    }
                    VStack {
                        Text("\(showFriendData.followerCount)")
                        Text("フォロワー")
                    }
                }
                Spacer()
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
