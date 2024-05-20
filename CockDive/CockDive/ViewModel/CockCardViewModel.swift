import Foundation

class CockCardViewModel: ObservableObject {
    let userDataModel = UserDataModel()
    let userFriendModel = UserFriendModel()
    let postDataModel = PostDataModel()
    
    /// uid取得
    func fetchUid() -> String {
        return userDataModel.fetchUid() ?? ""
    }
    
    // MARK: - データ追加
    /// Post追加/ 更新
    func addPost(post: PostElement) async {
        await postDataModel.addPost(post: post)
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
    func reportUser(friendUid: String) {
        // TODO: 通報処理書く
    }
}
