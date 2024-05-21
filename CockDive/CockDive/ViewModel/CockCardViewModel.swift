import Foundation
import FirebaseFirestore

class CockCardViewModel: ObservableObject {
    @Published var showPostData: PostElement? = nil
    let userDataModel = UserDataModel()
    let userFriendModel = UserFriendModel()
    let postDataModel = PostDataModel()
    
    private var postListener: ListenerRegistration? = nil
    
    /// uid取得
    func fetchUid() -> String {
        return userDataModel.fetchUid() ?? ""
    }
    
    // MARK: - データのリッスン
    /// Postをリアルタイムでリッスン
    func listenToPost(postId: String) {
        // 既存のリスナーを削除
        stopListeningToPosts()
        
        // 新しいリスナーを設定
        postListener = postDataModel.listenToPostData(postId: postId) { [weak self] postsData in
            DispatchQueue.main.async {
                self?.showPostData = postsData
            }
        }
    }
    
    /// リスナーを停止
    func stopListeningToPosts() {
        postListener = nil
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
    
    // MARK: - その他
    /// フォローしているか判定
    func checkIsFollow(userFriendData: UserFriendElement?, friendUid: String) -> Bool {
        guard let userFriendData else { return false }
        
        if userFriendData.follow.contains(friendUid) {
            return true
        } else {
            return false
        }
    }
    
    /// ライクしているか判定
    func checkIsLike(postData: PostElement) -> Bool {
        let uid = fetchUid()
        if postData.likedUser.contains(uid) {
            return true
        } else {
            return false
        }
    }
}
