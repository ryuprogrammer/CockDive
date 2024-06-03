import Foundation
import FirebaseFirestore
import CoreData

class CockCardViewModel: ObservableObject {
    @Published var postData: PostElement? = nil
    @Published var userData: UserElement? = nil

    let userDataModel = UserDataModel()
    let userFriendModel = UserFriendModel()
    let userPostDataModel = UserPostDataModel()
    let postDataModel = PostDataModel()
    let coreDataMyDataModel = MyDataCoreDataManager.shared
    let coreDataLikePostModel = LikePostCoreDataManager.shared

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
                if let postsData {
                    self?.postData = postsData
                }
            }
        }
    }

    /// リスナーを停止
    func stopListeningToPosts() {
        postListener = nil
    }

    // MARK: - データの取得
    /// UserData取得
    func fetchUserData(uid: String) async {
        let user = await userDataModel.fetchUserData(uid: uid)
        DispatchQueue.main.async {
            guard let userData = user else { return }
            self.userData = userData
        }
    }

    // MARK: - データ追加
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

    // MARK: - CoreData
    /// ライクしているか判定（CoreData）
    func checkIsLike(postId: String?) -> Bool {
        if let postId {
            return coreDataLikePostModel.checkIsLike(id: postId)
        }
        return false
    }

    /// フォローしているか判定
    func checkIsFollow(friendUid: String?) -> Bool {
        if let friendUid {
            return coreDataMyDataModel.checkIsFollow(uid: friendUid)
        }
        return false
    }
}
