import Foundation

class MyPageViewModel: ObservableObject {
    /// UserDefaultsの基本データ（ニックネーム、自己紹介、アイコン）
    @Published var userData: UserElementForUserDefaults? = nil
    /// UserFriendElement（フォロー、フォロワー）
    @Published var friendData: UserFriendElement? = nil
    /// 投稿データ
    @Published var myPostData: [(day: Int, post: MyPostModel)] = []
    /// 投稿数
    @Published var myPostCount: Int = 0

    let userDefaultsDataModel = UserDefaultsDataModel()
    let userFriendModel = UserFriendModel()
    let myPostManager = MyPostCoreDataManager.shared

    // MARK: - データ取得
    /// 基本データ取得（ニックネーム、自己紹介、アイコン）
    func fetchUserData() {
        userData = userDefaultsDataModel.fetchUserData()
    }

    /// UserFriendElement取得（フォロー、フォロワー）
    func fetchUserFriendElement(uid: String) async {
        friendData = await userFriendModel.fetchUserFriendData(uid: uid)
    }

    /// 投稿データ取得
    func fetchMyPostData(date: Date) {
        myPostData = myPostManager.fetchByMonth(date: date)
    }

    /// 投稿数取得
    func fetchMyPostCount() {
        myPostCount = myPostManager.countAllPosts()
    }
}
