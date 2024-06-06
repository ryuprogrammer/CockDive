import Foundation
import FirebaseFirestore

class PostDetailViewModel: ObservableObject {
    @Published var postData: PostElement?
    @Published var userData: UserElement?
    @Published var isLike: Bool = false
    @Published var isFollow: Bool = false

    let userDataModel = UserDataModel()
    let userFriendModel = UserFriendModel()
    let userPostDataModel = UserPostDataModel()
    let postDataModel = PostDataModel()
    let commentDataModel = CommentDataModel()
    let coreDataMyDataModel = MyDataCoreDataManager.shared
    let userDefaultsDataModel = UserDefaultsDataModel()
    let coreDataLikePostModel = LikePostCoreDataManager.shared
    let reportDataModel = ReportDataModel()

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

    // 初期値設定用メソッド
    func initialize(
        firstLike: Bool,
        firstFollow: Bool
    ) {
        self.isLike = firstLike
        self.isFollow = firstFollow
    }

    // MARK: - データ追加
    /// コメント更新（追加/削除）
    func updateComment(
        post: PostElement,
        newComment: CommentElement
    ) {
        commentDataModel.updateComment(post: post, newComment: newComment)
    }

    /// コメント削除
    func deleteComment(
        post: PostElement,
        commentToDelete: CommentElement
    ) {
        commentDataModel.deleteComment(post: post, commentToDelete: commentToDelete)
    }

    /// Like変更（CoreDataとFirestore（UserPostDataModelとPostDataModel））
    func likePost(
        post: PostElement,
        toLike: Bool
    ) async {
        guard let id = post.id else { return }
        // CoreDataのライク変更
        coreDataLikePostModel.toggleLikePost(id: id, toLike: toLike)
        // FirestoreのPostDataModelのライク変更
        await postDataModel.changeLikeToPost(post: post, toLike: toLike)
        // FirestoreのUserPostDataModelのライク変更
        await userPostDataModel.addPostId(postId: id, userPostType: .like)
    }

    /// フォロー変更（CoreDataとFirestore）
    func followUser(
        friendUid: String
    ) async {
        // CoreDataのフォロー変更
        coreDataMyDataModel.changeFollow(uid: friendUid)
        // Firestoreのフォロー変更
        await userFriendModel.addUserFriend(friendUid: friendUid, friendType: .follow)
    }

    /// ブロック
    func blockUser(
        friendUid: String
    ) async {
        await userFriendModel.addUserFriend(friendUid: friendUid, friendType: .block)
    }

    /// Userを通報
    func reportUser(
        reportedUid: String,
        post: PostElement,
        reason: String
    ) async {
        guard let postId = post.id else { return }
        let report = ReportElement(
            reportedUserID: reportedUid,
            reportingUserID: fetchUid(),
            reason: reason,
            createAt: Date(),
            postID: postId
        )
        do {
            try await reportDataModel.addReport(report: report)
            print("Post reported successfully.")
        } catch {
            print("Failed to report post: \(error.localizedDescription)")
        }
    }

    /// 投稿通報
    func reportPost(
        post: PostElement,
        reason: String
    ) async {
        guard let postId = post.id else { return }
        let report = ReportElement(
            reportedUserID: post.uid,
            reportingUserID: fetchUid(),
            reason: reason,
            createAt: Date(),
            postID: postId
        )
        do {
            try await reportDataModel.addReport(report: report)
            print("Post reported successfully.")
        } catch {
            print("Failed to report post: \(error.localizedDescription)")
        }
    }

    // MARK: - データ取得

    /// uid取得
    func fetchUid() -> String {
        return userDataModel.fetchUid() ?? ""
    }

    /// Post取得
    func fetchPostData(postId: String?) async {
        guard let postId = postId else { return }
        let postData = await postDataModel.fetchPostFromPostId(postId: postId)
        DispatchQueue.main.async {
            self.postData = postData
        }
    }

    /// userData取得
    func fetchUserData(uid: String) async {
        let user = await userDataModel.fetchUserData(uid: uid)
        DispatchQueue.main.async {
            guard let userData = user else { return }
            self.userData = userData
        }
    }

    /// 自分の投稿か判定
    func checkIsMyPost(uid: String) -> Bool {
        let myUid = fetchUid()
        if uid == myUid {
            return true
        } else {
            return false
        }
    }

    // MARK: - CoreData
    /// ライクしているか判定（CoreData）
    func checkIsLike(postId: String?) {
        if let postId {
            isLike = coreDataLikePostModel.checkIsLike(id: postId)
        }
    }

    /// フォローしているか判定
    func checkIsFollow(friendUid: String?) {
        if let friendUid {
            isFollow = coreDataMyDataModel.checkIsFollow(uid: friendUid)
            print("フォロー: \(isFollow)")
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

    // MARK: - データ削除
    /// 投稿を削除: firebaseとCoreData
    func deletePost(postId: String?) async {
        guard let id = postId else { return }
        do {
            // firebaseから削除
            try await postDataModel.deletePost(postId: id)
            // CoreDataから削除
            MyPostCoreDataManager.shared.delete(by: id)
            print("Post deleted successfully.")
        } catch {
            print("Failed to delete post: \(error.localizedDescription)")
        }
    }
}
