import Foundation

struct UserDefaultsDataModel {
    var userKey: String = "userKey"
    
    /// userデータ追加/ 更新
    func addUserData(user: UserElement) {
        let saveData: UserElementForUserDefaults = UserElementForUserDefaults(
            nickName: user.nickName,
            introduction: user.introduction,
            iconImage: user.iconImage,
            iconURL: user.iconURL
        )
        
        do {
            let encoded = try JSONEncoder().encode(saveData)
            UserDefaults.standard.set(encoded, forKey: userKey)
        } catch {
            print("Error encoding user data: \(error)")
        }
    }
    
    /// userデータ取得
    func fetchUserData() -> UserElementForUserDefaults? {
        guard let savedData = UserDefaults.standard.data(forKey: userKey) else {
            return nil
        }
        do {
            let decoded = try JSONDecoder().decode(UserElementForUserDefaults.self, from: savedData)
            return decoded
        } catch {
            print("Error decoding user data: \(error)")
            return nil
        }
    }
    
    /// userデータが存在するか判定するメソッド
    func userDataExists() -> Bool {
        let userExists = UserDefaults.standard.object(forKey: userKey) != nil
        print("user: \(fetchUserData()?.nickName ?? "notino")")
        print("object: \(userExists)")
        return userExists
    }
}
