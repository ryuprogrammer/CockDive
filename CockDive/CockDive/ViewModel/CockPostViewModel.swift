import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreData

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

    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String {
        return postDataModel.fetchUid() ?? ""
    }

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

    /// 最後に取得したDocmentIdを基準にさらにPostを取得
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
                print("error fetchMorePosts: \(error)")
                // エラーが発生した場合の処理
                DispatchQueue.main.async {
                    self.loadStatus = .error
                }
            }
        }
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
