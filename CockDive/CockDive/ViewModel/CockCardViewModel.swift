import Foundation

class CockCardViewModel {
    let userDataModel = UserDataModel()
    
    /// uidからUserData取得
    func fetchUserData(uid: String) async -> UserElement? {
        return await userDataModel.fetchUserData(uid: uid)
    }
    
    /// ハートを押す
    
}
