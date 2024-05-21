import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CockPostViewModel: ObservableObject {
    // PostDataを取得
    @Published var postsData: [PostElement] = []
    
    // ロードステータス
    private var loadStatus: LoadStatus = .initial
    let userDataModel = UserDataModel()
    var postDataModel = PostDataModel()
    let userFriendDataModel = UserFriendModel()
    let userPostDataModel = UserPostDataModel()
    
    private var postListeners: [ListenerRegistration] = []
    
    // ロードステータス
    private enum LoadStatus {
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
    /// Postを複数取得
    func fetchPosts() async {
        let datas = await postDataModel.fetchPostIdData()
        DispatchQueue.main.async {
            self.postsData = datas
        }
    }
    
    /// 最後に取得したDocmentIdを基準にさらにPostIdを取得
    func fetchMorePosts() async {
        // .loadingの時以外、処理を実行する
        guard self.loadStatus != .loading else { return }
        // ロード開始のステータスに変更
        self.loadStatus = .loading
        
        let lastDocumentId = postsData.last?.id ?? ""
        await postDataModel.fetchMorePostData(lastDocumentId: lastDocumentId) { result in
            switch result {
            case .success(let posts):
                // データの取得が成功した場合の処理
                DispatchQueue.main.async {
                    self.postsData.append(contentsOf: posts)
                    print("新しく取得したデータ数: \(posts.count)")
                    print("全ての投稿数: \(self.postsData.count)")
                }
                self.loadStatus = .completion
            case .failure(let error):
                // エラーが発生した場合の処理
                self.loadStatus = .error
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
        if postData.id == postsData.last?.id {
            return true
        }
        return false
    }
}
