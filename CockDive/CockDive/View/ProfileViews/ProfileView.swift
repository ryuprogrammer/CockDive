import SwiftUI

struct ProfileView: View {
    @State var showUser: UserElement
    let firstFollow: Bool

    // このViewで取得
    @State private var showUserFriends: UserFriendElement = UserFriendElement(
        followCount: 0,
        follow: [],
        followerCount: 0,
        follower: [],
        block: [],
        blockedByFriend: []
    )
    @State private var showUserPosts: UserPostElement = UserPostElement(
        postCount: 0,
        posts: [],
        likePostCount: 0,
        likePost: []
    )

    var body: some View {
        VStack {
            Text("Hello, \(showUser.nickName)!")
            Text("Introduction: \(showUser.introduction ?? "No introduction")")
            Text("Followers: \(showUserFriends.followerCount)")
            Text("Posts: \(showUserPosts.postCount)")
        }
        .onAppear {
            // UserFriendElementとUserPostElementのデータ取得ロジックをここに追加
            // 例えば、Firebase Firestoreからデータを取得するコード
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
            firstFollow: false
        )
    }
}

///　プロフィール情報
///　カレンダー

/// 通報、ブロック
/// フォロー
/// 投稿リスト、カレンダー
