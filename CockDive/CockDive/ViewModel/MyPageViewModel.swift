import Foundation

class MyPageViewModel: ObservableObject {
    /// UserDefaultsの基本データ（ニックネーム、自己紹介、アイコン）
    @Published var userData: UserElementForUserDefaults? = nil
    /// UserFriendElement（フォロー、フォロワー）
    @Published var friendData: UserFriendElement? = nil
    /// 投稿数
    @Published var myPostCount: Int = 0
    // ロードステータス
    @Published var loadStatusMyPost: LoadStatus = .initial
    @Published var loadStatusLikePost: LoadStatus = .initial
    /// 投稿リスト用
    @Published var newMyPostListData: [PostElement] = []
    /// ライクした投稿
    @Published var newLikePostListData: [PostElement] = []

    let userDefaultsDataModel = UserDefaultsDataModel()
    let userFriendModel = UserFriendModel()
    let myPostManager = MyPostCoreDataManager.shared
    let postDataModel = PostDataModel()

    // ロードステータス
    enum LoadStatus {
        case initial
        case loading
        case completion
        case error
    }

    // MARK: - データ取得
    /// 基本データ取得（ニックネーム、自己紹介、アイコン）
    func fetchUserData() {
        userData = userDefaultsDataModel.fetchUserData()
    }

    /// UserFriendElement取得（フォロー、フォロワー）
    func fetchUserFriendElement() async {
        if let uid = userFriendModel.fetchUid() {
            let friend = await userFriendModel.fetchUserFriendData(uid: uid)
            DispatchQueue.main.async {
                self.friendData = friend
            }
        }
    }

    /// 投稿データ取得
    func fetchMyPostData(date: Date) -> [(day: Int, posts: [MyPostModel])] {
        return myPostManager.fetchByMonth(date: date)
    }

    /// 投稿数取得
    func fetchMyPostCount() {
        myPostCount = myPostManager.countAllPosts()
    }

    // MARK: - 自分の投稿

    /// PostをloadStatusに応じて取得
    func fetchMyPostsDataByStatus(lastId: String?) async {
        switch loadStatusMyPost {
        case .initial: // 初回は普通にデータ取得
            await fetchPostFromUid()
        case .loading: // 取得中なので、何もしない
            return
        case .completion, .error:
            guard let lastId else { return }
            await fetchMorePosts(lastDocumentId: lastId)
        }
    }

    /// UidからPost取得
    func fetchPostFromUid() async {
        guard let uid = postDataModel.fetchUid() else { return }
        let postData = await postDataModel.fetchPostFromUid(uid: uid)
        DispatchQueue.main.async {
            self.newMyPostListData = postData
            self.loadStatusMyPost = .completion
        }
    }

    /// 最後に取得したDocmentIdを基準にさらにPostを取得
    func fetchMorePosts(lastDocumentId: String) async {
        DispatchQueue.main.async {
            // ロード開始のステータスに変更
            self.loadStatusMyPost = .loading
        }
        guard let uid = postDataModel.fetchUid() else { return }
        await postDataModel.fetchMorePostDataFromUid(uid: uid, lastDocumentId: lastDocumentId) { result in
            switch result {
            case .success(let posts):
                // データの取得が成功した場合の処理
                DispatchQueue.main.async {
                    self.newMyPostListData = posts
                    self.loadStatusMyPost = .completion
                }
            case .failure(let error):
                print("fetchMorePosts: error: \(error)")
                // エラーが発生した場合の処理
                DispatchQueue.main.async {
                    self.loadStatusMyPost = .error
                }
            }
        }
    }

    // MARK: - いいねした投稿

    /// PostをloadStatusに応じて取得
    func fetchLikePostsDataByStatus(lastId: String?) async {
        switch loadStatusMyPost {
        case .initial: // 初回は普通にデータ取得
            await fetchPostFromUid()
        case .loading: // 取得中なので、何もしない
            return
        case .completion, .error:
            guard let lastId else { return }
            await fetchMorePosts(lastDocumentId: lastId)
        }
    }

    // MARK: - その他
    /// 表示されたPostが最後か判定
    func checkIsLastPost(postData: PostElement) -> Bool {
        if postData.id == newMyPostListData.last?.id {
            return true
        }
        return false
    }
}
