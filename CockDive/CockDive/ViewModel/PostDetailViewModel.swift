import Foundation
import FirebaseFirestore

class PostDetailViewModel: ObservableObject {
    @Published var postData: PostElement?
    @Published var isFollow: Bool = false
    
    let userDataModel = UserDataModel()
    let userFriendModel = UserFriendModel()
    let postDataModel = PostDataModel()
    let commentDataModel = CommentDataModel()
    
    // ロードステータス
    private var loadStatus: LoadStatus = .initial
    
    private var postListener: ListenerRegistration? = nil
    
    // ロードステータス
    private enum LoadStatus {
        case initial
        case loading
        case completion
        case error
    }
    
    // MARK: - データ追加
    /// コメント更新（追加/ 削除）
    func updateComment(post: PostElement, comments: [CommentElement]) {
        commentDataModel.updateComment(post: post, newComments: comments)
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
    
    /// postIdからPostDataを取得
    func fetchPostFromPostId(postId: String) async -> PostElement? {
        return await postDataModel.fetchPostFromPostId(postId: postId)
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
    
    // MARK: - データのリッスン
    /// Postをリアルタイムでリッスン
    func listenToPost(postId: String?) {
        guard let postId else { return }
        // 既存のリスナーを削除
        stopListeningToPosts()
        
        // 新しいリスナーを設定
        postListener = postDataModel.listenToPostData(postId: postId) { [weak self] postsData in
            DispatchQueue.main.async {
                self?.postData = postsData
            }
        }
    }
    
    /// リスナーを停止
    func stopListeningToPosts() {
        postListener = nil
    }
}
