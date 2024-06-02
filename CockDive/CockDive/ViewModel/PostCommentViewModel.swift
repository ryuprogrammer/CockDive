import Foundation

class PostCommentViewModel: ObservableObject {
    @Published var nickName: String = ""
    @Published var iconData: Data?
    @Published var userData: UserElement?

    let userDataModel = UserDataModel()

    // MARK: - データ取得
    func fetchUserData(uid: String) async {
        let user = await userDataModel.fetchUserData(uid: uid)
        DispatchQueue.main.async {
            guard let userData = user else { return }
            self.userData = userData
        }
    }
}
