import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CockPostViewModel: ObservableObject {
    // Viewで使用するPostData
    @Published var postData: [PostElement] = []
    // PostDataを取得するためのId: 追加する分のみ
    @Published var postIds: [String] = []
    let userDataModel = UserDataModel()
    var postDataModel = PostDataModel()
    let userFriendDataModel = UserFriendModel()
    let userPostDataModel = UserPostDataModel()
    
    private var postListeners: [ListenerRegistration] = []

    // MARK: - データ追加
    /// Like
    func likePost(post: PostElement) async {
        await postDataModel.changeLikeToPost(post: post)
    }
    
    /// フォロー
    func followUser(friendUid: String) async {
        await userFriendDataModel.addUserFriend(friendUid: friendUid, friendType: .follow)
    }
    
    /// ブロック
    func blockUser(friendUid: String) async {
        await userFriendDataModel.addUserFriend(friendUid: friendUid, friendType: .block)
    }
    
    /// 通報
    func reportUser(friendUid: String) {
        // TODO: 通報処理書く
    }
    
    // MARK: - データ取得
    /// PostIdを取得
    func fetchPostIds() async {
        let ids = await postDataModel.fetchPostIdData()
        DispatchQueue.main.async {
            self.postIds = ids
        }
    }
    
    /// 最後に取得したDocmentIdを基準にさらにPostIdを取得
    func fetchMorePostIds() async {
        let lastDocumentId = postIds.last
        let morePostIds: [String] = await postDataModel.fetchMorePostIdData(lastDocumentId: lastDocumentId)
        DispatchQueue.main.async {
            self.postIds = morePostIds
        }
    }
    
    /// uid取得
    func fetchUid() -> String {
        return postDataModel.fetchUid() ?? ""
    }
    
    /// userData取得
    func fetchUserData() async -> UserElement? {
        let uid = fetchUid()
        return await userDataModel.fetchUserData(uid: uid)
    }
    
    /// UserFriendElement取得
    func fetchUserFriendElement() async -> UserFriendElement? {
        let uid = fetchUid()
        return await userFriendDataModel.fetchUserFriendData(uid: uid)
    }
    
    /// UserPostElement取得
    func fetchUserPostElement() async -> UserPostElement? {
        let uid = fetchUid()
        return await userPostDataModel.fetchUserPostData(uid: uid)
    }
    
    // MARK: - データのリッスン
    /// 複数のPostをリアルタイムでリッスン→onChangeで使用
    func listenToPosts(postIds: [String]) {
        // 既存のリスナーを削除
        stopListeningToPosts()
        
        // 新しいリスナーを設定
        postListeners = postDataModel.listenToPostsData(postIds: postIds) { [weak self] postsData in
            DispatchQueue.main.async {
                self?.postData = postsData
            }
        }
    }
    
    /// リスナーを停止
    func stopListeningToPosts() {
        postListeners.forEach { $0.remove() }
        postListeners.removeAll()
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
