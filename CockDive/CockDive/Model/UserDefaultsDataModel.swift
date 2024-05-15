import Foundation

struct UserDefaultsDataModel {
    let userDataModel = UserDataModel()
    let userKey: String = "userKey"
    
    /// userデータ追加/ 更新
    func addUserData(user: UserElement) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    /// userデータ取得
    func fetchUserData() -> UserElement? {
        if let savedData = UserDefaults.standard.object(forKey: userKey) as? Data {
            if let decoded = try? JSONDecoder().decode(UserElement.self, from: savedData) {
                return decoded
            }
        }
        return nil
    }
    
    /// userデータが存在するか判定するメソッド
    func userDataExists() -> Bool {
        return UserDefaults.standard.object(forKey: userKey) != nil
    }
}
