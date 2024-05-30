import Foundation

class BlockListViewModel: ObservableObject {
    @Published var newBlockUserData: [UserElement] = []
    // ロードステータス
    @Published var loadStatus: LoadStatus = .initial
    var remainingUids: [String] = []
    let userFriendModel = UserFriendModel()
    let myDataCoreDataManager = MyDataCoreDataManager.shared

    // ロードステータス
    enum LoadStatus {
        case initial
        case loading
        case completion
        case error
    }

    // MARK: - データ取得
    /// PostをloadStatusに応じて取得
    func fetchBlockUserByStatus() async {
        switch loadStatus {
        case .initial: // 初回は普通にデータ取得
            await fetchBlockUid()
            await fetchBlockUserData()
        case .loading: // 取得中なので、何もしない
            return
        case .completion, .error:
            await fetchBlockUserData()
        }
    }

    /// ブロックのuidを取得
    func fetchBlockUid() async {
        remainingUids = await userFriendModel.fetchFriendUidsByType(friendType: .block)
    }

    /// ブロックデータ取得
    func fetchBlockUserData() async {
        let userData = await userFriendModel.fetchUserDataWithLimit(uids: remainingUids)
        remainingUids = userData.remainingUids
        DispatchQueue.main.async {
            self.newBlockUserData = userData.userData
        }
    }

    /// ブロック解除
    func removeBlockUser(uid: String) async {
        await userFriendModel.removeBlockForUser(uid: uid)
    }
}
