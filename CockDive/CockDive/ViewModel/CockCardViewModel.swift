import Foundation

// TODO: - 5/20中のタスクだお
/// @PublishのnickNameとか全部消す。
/// postDataにnickNameとiconImageURL入ってるから。
///
/// フォローとライクの実装をする。
/// PostDetailViewを参考に。
class CockCardViewModel: ObservableObject {
    @Published var nickName: String = ""
    @Published var iconImageURL: URL? = URL(string: "")
    @Published var isFollow: Bool = false
    
    let userDataModel = UserDataModel()
    let userFriendModel = UserFriendModel()
    let postDataModel = PostDataModel()
    
    /// データの初期化
    @MainActor
    func initData(friendUid: String) async {
        do {
            if let userData = try await fetchUserData(uid: friendUid) {
                self.nickName = userData.nickName
                self.iconImageURL = URL(string: userData.iconURL ?? "")
            }
        } catch {
            print("Error fetching user data: \(error)")
        }
    }
    
    /// フォローしているか判定
    func isFollowFriend(friendUid: String) async {
        guard let uid = userDataModel.fetchUid() else { return }
        if let userFriendData = await  userFriendModel.fetchUserFriendData(uid: uid) {
            if userFriendData.follow.contains(friendUid) {
                DispatchQueue.main.async {
                    self.isFollow = true
                }
            }
        }
    }
    
    /// uidからUserData取得
    func fetchUserData(uid: String) async throws -> UserElement? {
        return await userDataModel.fetchUserData(uid: uid)
    }
    
    // MARK: - データ追加
    /// Post追加/ 更新
    func addPost(post: PostElement) async {
        await postDataModel.addPost(post: post)
    }
    
    /// Like
    func likePost(post: PostElement) async {
        await postDataModel.changeLikeToPost(post: post)
    }
    
    /// フォロー
    func followUser(friendUid: String) async {
        await userFriendModel.addUserFriend(friendUid: friendUid, friendType: .follow)
    }
    
    /// ブロック
    func blockUser(friendUid: String) async {
        await userFriendModel.addUserFriend(friendUid: friendUid, friendType: .block)
    }
    
    /// 通報
    func reportUser(friendUid: String) {
        // TODO: 通報処理書く
    }
}
