import Foundation

class ProfileViewModel: ObservableObject {
    @Published var userFriends: UserFriendElement?
    @Published var userPosts: UserPostElement?
    @Published var showPostData: [PostElement] = []
    @Published var isFollow: Bool = false

    // 投稿のid、いいねした投稿のidを取得
    let userPostDataModel = UserPostDataModel()
    // フォローとかフォロワーを取得
    let userFriendModel = UserFriendModel()
    let postDataModel = PostDataModel()
    let coreDataMyDataModel = MyDataCoreDataManager.shared

    // MARK: - データ取得
    /// UserFriendElement取得
    func fetchUserFriendData(uid: String) async {
        let userFriends = await userFriendModel.fetchUserFriendData(uid: uid)
        DispatchQueue.main.async {
            self.userFriends = userFriends
        }
    }

    /// UserPostElement取得
    func fetchUserPostElement(uid: String) async {
        let userPosts = await userPostDataModel.fetchUserPostData(uid: uid)
        DispatchQueue.main.async {
            self.userPosts = userPosts
        }
    }

    /// PostIdからPost取得
    func fetchPostFromUid(uid: String) async {
        let postData = await postDataModel.fetchPostFromUid(uid: uid)
        DispatchQueue.main.async {
            self.showPostData = postData
        }
    }

    // MARK: - データ追加
    /// フォロー変更（CoreDataとFirestore）
    func followUser(friendUid: String) async {
        // CoreDataのフォロー変更
        coreDataMyDataModel.changeFollow(uid: friendUid)
        // Firestoreのフォロー変更
        await userFriendModel.addUserFriend(friendUid: friendUid, friendType: .follow)
    }

    /// ブロック
    func blockUser(friendUid: String) async {
        await userFriendModel.addUserFriend(friendUid: friendUid, friendType: .block)
    }

    /// 通報
    func reportUser(friendUid: String) {
        // TODO: 通報処理書く
    }

    // MARK: - CoreData
    /// フォローしているか判定
    func checkIsFollow(friendUid: String?) {
        if let friendUid {
            self.isFollow = coreDataMyDataModel.checkIsFollow(uid: friendUid)
        }
    }
}
