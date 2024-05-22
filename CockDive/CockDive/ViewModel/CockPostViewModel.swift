import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CockPostViewModel: ObservableObject {
    // PostDataを取得
    @Published var newPostsData: [PostElement] = []
    // ロードステータス
    @Published var loadStatus: LoadStatus = .initial
    let userDataModel = UserDataModel()
    var postDataModel = PostDataModel()
    let userFriendDataModel = UserFriendModel()
    let userPostDataModel = UserPostDataModel()

    private var postListeners: [ListenerRegistration] = []

    // ロードステータス
    enum LoadStatus {
        case initial
        case loading
        case completion
        case error
    }

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
    /// PostをloadStatusに応じて取得
    func fetchPostsDataByStatus() async {
        switch loadStatus {
        case .initial: // 初回は普通にデータ取得
            await fetchPosts()
        case .loading: // 取得中なので、何もしない
            return
        case .completion, .error:
            await fetchMorePosts()
        }
    }
    /// Postを複数取得
    func fetchPosts() async {
        let datas = await postDataModel.fetchPostIdData()
        DispatchQueue.main.async {
            self.newPostsData = datas
            self.loadStatus = .completion
        }
    }

    /// 最後に取得したDocmentIdを基準にさらにPostIdを取得
    func fetchMorePosts() async {
        DispatchQueue.main.async {
            // ロード開始のステータスに変更
            self.loadStatus = .loading
        }
        let lastDocumentId = newPostsData.last?.id ?? ""
        await postDataModel.fetchMorePostData(lastDocumentId: lastDocumentId) { result in
            switch result {
            case .success(let posts):
                // データの取得が成功した場合の処理
                DispatchQueue.main.async {
                    self.newPostsData = posts
                    self.loadStatus = .completion
                }
            case .failure(let error):
                // エラーが発生した場合の処理
                DispatchQueue.main.async {
                    print("エラーーーーーーー: \(error)")
                    self.loadStatus = .error
                }
            }
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

    // MARK: - その他
    /// 表示されたPostが最後か判定
    func checkIsLastPost(postData: PostElement) -> Bool {
        if postData.id == newPostsData.last?.id {
            return true
        }
        return false
    }
}
