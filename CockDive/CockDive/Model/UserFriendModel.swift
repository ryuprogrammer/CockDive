import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserFriendModel {
    /// コレクション名
    private let userFriendCollection: String = "userFriendData"
    
    private var db = Firestore.firestore()
    
    // MARK: - データ追加
    /// UserFriend追加/ 更新
    func addUser(user: UserElement) async {
        // uid取得
        guard let uid = fetchUid() else { return }
        
        do {
            // 指定したUIDを持つドキュメントデータに追加（または更新）
            try db.collection(userFriendCollection).document(uid).setData(from: user)
            
            print("addUser完了")
        } catch {
            print("Error adding/updating user: \(error)")
        }
    }
    
    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// uidを指定してuserFriendDataを取得
    func fetchUserData(uid: String) async -> UserElement? {
        do {
            let document = try await db.collection(userFriendCollection).document(uid).getDocument()
            
            guard document.data() != nil else {
                print("Document does not exist")
                return nil
            }
            
            let decodedUserData = try document.data(as: UserElement.self)
            
            // 使用するデータに応じて処理を追加
            print(decodedUserData)
            return decodedUserData
        } catch {
            print("Error fetching user data: \(error)")
        }
        return nil
    }
}
