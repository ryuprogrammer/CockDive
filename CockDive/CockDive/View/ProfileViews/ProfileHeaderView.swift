import SwiftUI

struct ProfileHeaderView: View {
    var showUser: UserElement
    var showUserFriends: UserFriendElement
    var showUserPosts: UserPostElement
    var screenWidth: CGFloat

    var body: some View {
        HStack {
            if let data = showUser.iconImage,
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
                    Text("\(showUserPosts.postCount)")
                    Text("投稿")
                }
                VStack {
                    Text("\(showUserFriends.followCount)")
                    Text("フォロー")
                }
                VStack {
                    Text("\(showUserFriends.followerCount)")
                    Text("フォロワー")
                }
            }
            Spacer()
        }
    }
}
