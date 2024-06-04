import Foundation

class ProfileViewModel: ObservableObject {
    @Published var userFriends: UserFriendElement?
    @Published var userPosts: UserPostElement?
    @Published var newPostsData: [PostElement] = []
    @Published var isFollow: Bool = false
    // ロードステータス
    @Published var loadStatus: LoadStatus = .initial
    // 投稿のid、いいねした投稿のidを取得
    let userPostDataModel = UserPostDataModel()
    // フォローとかフォロワーを取得
    let userFriendModel = UserFriendModel()
    let postDataModel = PostDataModel()
    let coreDataMyDataModel = MyDataCoreDataManager.shared
    let reportDataModel = ReportDataModel()
    let userDataModel = UserDataModel()

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
        return userDataModel.fetchUid() ?? ""
    }

    /// PostをloadStatusに応じて取得
    func fetchPostsDataByStatus(uid: String, lastId: String?) async {
        switch loadStatus {
        case .initial: // 初回は普通にデータ取得
            await fetchPostFromUid(uid: uid)
        case .loading: // 取得中なので、何もしない
            return
        case .completion, .error:
            guard let lastId else { return }
            await fetchMorePosts(uid: uid, lastDocumentId: lastId)
        }
    }

    /// UserFriendElement取得
    func fetchUserFriendData(uid: String) async {
        let userFriends = await userFriendModel.fetchUserFriendData(uid: uid)
        DispatchQueue.main.async {
            self.userFriends = userFriends
        }
    }

    /// UserPostElement取得
    func fetchUserPostElement(uid: String) async {
        let userPosts = await userPostDataModel.fetchUserPostData(uid: uid)
        DispatchQueue.main.async {
            self.userPosts = userPosts
        }
    }

    /// UidからPost取得
    func fetchPostFromUid(uid: String) async {
        let postData = await postDataModel.fetchPostFromUid(uid: uid)
        DispatchQueue.main.async {
            self.newPostsData = postData
            self.loadStatus = .completion
            print("デーーーーーーーたpostData: \(postData.count)")
        }
    }

    /// 最後に取得したDocmentIdを基準にさらにPostを取得
    func fetchMorePosts(uid: String, lastDocumentId: String) async {
        DispatchQueue.main.async {
            // ロード開始のステータスに変更
            self.loadStatus = .loading
        }
        await postDataModel.fetchMorePostDataFromUid(uid: uid, lastDocumentId: lastDocumentId) { result in
            switch result {
            case .success(let posts):
                // データの取得が成功した場合の処理
                DispatchQueue.main.async {
                    self.newPostsData = posts
                    self.loadStatus = .completion
                }
            case .failure(let error):
                print("fetchMorePosts error: \(error)")
                // エラーが発生した場合の処理
                DispatchQueue.main.async {
                    self.loadStatus = .error
                }
            }
        }
    }

    // MARK: - データ追加
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

    /// Userを通報
    func reportUser(
        reportedUid: String?,
        reason: String
    ) async {
        guard let uid = reportedUid else { return }
        let report = ReportElement(
            reportedUserID: uid,
            reportingUserID: fetchUid(),
            reason: reason,
            createAt: Date(),
            postID: nil
        )
        do {
            try await reportDataModel.addReport(report: report)
            print("Post reported successfully.")
        } catch {
            print("Failed to report post: \(error.localizedDescription)")
        }
    }

    // MARK: - CoreData
    /// フォローしているか判定
    func checkIsFollow(friendUid: String?) {
        if let friendUid {
            self.isFollow = coreDataMyDataModel.checkIsFollow(uid: friendUid)
        }
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
