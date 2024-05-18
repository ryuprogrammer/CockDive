import Foundation

class PostDetailViewModel: ObservableObject {
    @Published var nickName: String = ""
    @Published var iconImageURL: URL? = URL(string: "")
    @Published var isFollow: Bool = false
    
    let userDataModel = UserDataModel()
    let userFriendModel = UserFriendModel()
    
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
}
