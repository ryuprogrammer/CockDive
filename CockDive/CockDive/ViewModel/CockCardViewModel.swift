import Foundation

class CockCardViewModel: ObservableObject {
    let friendUid: String
    @Published var nickName: String = ""
    @Published var iconImageURL: URL? = URL(string: "")
    
    let userDataModel = UserDataModel()
    
    init(friendUid: String) async {
        self.friendUid = friendUid
        
        Task {
            await self.initData()
        }
    }
    
    /// データの初期化
    private func initData() async {
        if let userData = await fetchUserData(uid: friendUid) {
            DispatchQueue.main.async {
                self.nickName = userData.nickName
                self.iconImageURL = URL(string: userData.iconURL ?? "")
            }
        }
    }
    
    /// uidからUserData取得
    func fetchUserData(uid: String) async -> UserElement? {
        return await userDataModel.fetchUserData(uid: uid)
    }
}
