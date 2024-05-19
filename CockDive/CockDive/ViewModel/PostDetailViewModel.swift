import Foundation

class PostDetailViewModel: ObservableObject {
    @Published var isFollow: Bool = false
    
    let userDataModel = UserDataModel()
    let userFriendModel = UserFriendModel()
    let postDataModel = PostDataModel()
    let commentDataModel = CommentDataModel()
    
    // MARK: - データ追加
    /// コメント更新（追加/ 削除）
    func updateComment(post: PostElement, comments: [CommentElement]) async {
        await commentDataModel.updateComment(post: post, newComments: comments)
    }
    
    /// Like
    func likePost(post: PostElement) async {
        await postDataModel.changeLikeToPost(post: post)
    }
    
    /// フォロー
    func followUser(friendUid: String) async {
        await userFriendModel.addUserFriend(friendUid: friendUid, friendType: .follow)
    }
    
    /// ブロック
    func blockUser(friendUid: String) async {
        await userFriendModel.addUserFriend(friendUid: friendUid, friendType: .block)
    }
    
    /// 通報
    func reportUser(friendUid: String) async {
        // TODO: 通報処理書く
    }
    
    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String {
        return postDataModel.fetchUid() ?? ""
    }
    
    /// userDate取得
    func fetchUserData() async -> UserElement? {
        let uid = fetchUid()
        return await userDataModel.fetchUserData(uid: uid)
    }
    
    /// フォローしているか判定
    func isFollowFriend(friendUid: String) async {
        guard let uid = userDataModel.fetchUid() else { return }
        if let userFriendData = await  userFriendModel.fetchUserFriendData(uid: uid) {
            if userFriendData.follow.contains(friendUid) {
                DispatchQueue.main.async {
                    self.isFollow = true
                }
            }
        }
    }
}
