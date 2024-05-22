import SwiftUI

struct ProfileView: View {
    @State var showUser: UserElement
    @State var showUserFriends: UserFriendElement
    @State var showUserPosts: UserPostElement

    var body: some View {
        VStack {
            Text("Hello, \(showUser.nickName)!")
            Text("Introduction: \(showUser.introduction ?? "No introduction")")
            Text("Followers: \(showUserFriends.followerCount)")
            Text("Posts: \(showUserPosts.postCount)")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(
            showUser: UserElement(
                nickName: "John Doe",
                introduction: "This is John",
                iconImage: nil,
                iconURL: nil
            ),
            showUserFriends: UserFriendElement(
                followCount: 100,
                follow: ["user1", "user2"],
                followerCount: 200,
                follower: ["user3", "user4"],
                block: ["user5"],
                blockedByFriend: ["user6"]
            ),
            showUserPosts: UserPostElement(
                postCount: 10,
                posts: ["post1", "post2"],
                likePostCount: 5,
                likePost: ["like1", "like2"]
            )
        )
    }
}

///　プロフィール情報
///　カレンダー

/// 通報、ブロック
/// フォロー
/// 投稿リスト、カレンダー
