import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CockPostViewModel: ObservableObject {
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
            self.postIds.append(contentsOf: morePostIds)
            print("新しく取得したデータ数: \(morePostIds.count)")
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
    
    /// リスナーを停止
    func stopListeningToPosts() {
        postListeners.forEach { $0.remove() }
        postListeners.removeAll()
    }
}
