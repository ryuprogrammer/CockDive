import Foundation
import FirebaseFirestore

class PostDetailViewModel: ObservableObject {
    @Published var postData: PostElement?
    @Published var showIsLikePost: Bool = false
    @Published var showIsFollow: Bool = false

    let userDataModel = UserDataModel()
    let userFriendModel = UserFriendModel()
    let userPostDataModel = UserPostDataModel()
    let postDataModel = PostDataModel()
    let commentDataModel = CommentDataModel()
    let coreDataMyDataModel = MyDataCoreDataManager.shared
    let userDefaultsDataModel = UserDefaultsDataModel()

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
    func updateComment(post: PostElement, newComment: CommentElement) {
        commentDataModel.updateComment(post: post, newComment: newComment)
    }
    
    /// Like変更（CoreDataとFirestore（UserPostDataModelとPostDataModel））
    func likePost(
        post: PostElement
    ) async {
        guard let id = post.id else { return }
        let toLike = !showIsLikePost
        // CoreDataのライク変更
        coreDataMyDataModel.changeLike(postId: id, toLike: toLike)
        // FirestoreのPostDataModelのライク変更
        await postDataModel.changeLikeToPost(post: post, toLike: toLike)
        // FirestoreのUserPostDataModelのライク変更
        await userPostDataModel.addPostId(postId: id, userPostType: .like)
    }

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
    func reportUser(friendUid: String) async {
        // TODO: 通報処理書く
    }
    
    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String {
        return userDataModel.fetchUid() ?? ""
    }
    /// userDate取得
    func fetchUserData() -> UserElementForUserDefaults? {
        if let userData = userDefaultsDataModel.fetchUserData() {
            return userData
        }
        return nil
    }
    
    /// postIdからPostDataを取得
    func fetchPostFromPostId(postId: String) async -> PostElement? {
        return await postDataModel.fetchPostFromPostId(postId: postId)
    }
    
    // MARK: - CoreData
    /// ライクしているか判定（CoreData）
    func checkIsLike(postId: String?) {
        if let postId {
            showIsLikePost = coreDataMyDataModel.checkIsLike(postId: postId)
            print("ライク:\(showIsLikePost)")
        }
    }

    /// フォローしているか判定
    func checkIsFollow(friendUid: String?) {
        if let friendUid {
            showIsFollow = coreDataMyDataModel.checkIsFollow(uid: friendUid)
            print("フォロー: \(showIsFollow)")
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
