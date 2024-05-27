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
    /// ライクした投稿のidデータ（CoreData）
    var remainingLikePostIdData: [LikePostModel] = []

    let userDefaultsDataModel = UserDefaultsDataModel()
    let userFriendModel = UserFriendModel()
    let myPostManager = MyPostCoreDataManager.shared
    let myDataManager = MyDataCoreDataManager.shared
    let coreDataLikePostModel = LikePostCoreDataManager.shared
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
            await fetchMyPosts()
        case .loading: // 取得中なので、何もしない
            return
        case .completion, .error:
            guard let lastId else { return }
            await fetchMoreMyPosts(lastDocumentId: lastId)
        }
    }

    /// 自分のPost取得
    private func fetchMyPosts() async {
        guard let uid = postDataModel.fetchUid() else { return }
        let postData = await postDataModel.fetchPostFromUid(uid: uid)
        DispatchQueue.main.async {
            self.newMyPostListData = postData
            self.loadStatusMyPost = .completion
        }
    }

    /// 最後に取得したDocmentIdを基準にさらにPostを取得（自分の）
    private func fetchMoreMyPosts(lastDocumentId: String) async {
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

    /// いいねした投稿をloadStatusに応じて取得
    func fetchLikePostsDataByStatus() async {
        switch loadStatusMyPost {
        case .initial:
            // ライクした投稿のidを初期化
            fetchLikePostIdData()
            // ライクした投稿を取得
            await fetchLikePosts(likePostIdData: remainingLikePostIdData)
        case .loading:
            // 取得中なので、何もしない
            return
        case .completion, .error:
            // ライクした投稿を取得
            await fetchLikePosts(likePostIdData: remainingLikePostIdData)
        }
    }

    // Core DataからlikePostIdDataの取得
    private func fetchLikePostIdData() {
        self.remainingLikePostIdData = coreDataLikePostModel.fetchAllLikePost()
    }

    /// ライクした投稿を取得
    private func fetchLikePosts(
        likePostIdData: [LikePostModel]
    ) async {
        DispatchQueue.main.async {
            // ロード開始のステータスに変更
            self.loadStatusLikePost = .loading
        }
        let postAndIds = await postDataModel.fetchLimitedPostsFromLikePosts(likePosts: remainingLikePostIdData)
        // 取得しきれなかったライクした投稿のidと日付
        self.remainingLikePostIdData = postAndIds.remainingLikePosts
        DispatchQueue.main.async {
            self.newLikePostListData = postAndIds.posts
            self.loadStatusLikePost = .completion
        }
    }

    // MARK: - その他
    /// 表示されたPostが最後か判定→自分の投稿用
    func checkIsLastMyPost(postData: PostElement) -> Bool {
        if postData.id == newMyPostListData.last?.id {
            return true
        }
        return false
    }

    /// 表示されたPostが最後か判定→いいね用
    func checkIsLastLikePost(postData: PostElement) -> Bool {
        if postData.id == newLikePostListData.last?.id {
            return true
        }
        return false
    }
}
