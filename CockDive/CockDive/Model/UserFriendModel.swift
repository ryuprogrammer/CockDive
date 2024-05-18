import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserFriendModel {
    /// コレクション名
    private let userFriendCollection: String = "userFriendData"
    
    private var db = Firestore.firestore()
    
    // MARK: - データ追加
    /// UserFriendDataを編集
    func addMUserFriend(friendUid: String, friendType: FriendType) async {
        // uid取得
        guard let myUid = fetchUid() else { return }
        // フォローしているか
        var isFollow: Bool = false
        // ブロックしているか
        var isBlock: Bool = false
        // フォローしてる数
        var followCount = 0
        
        // UserFriendElement取得
        if let userFriend = await fetchUserFriendData(uid: myUid) {
            if userFriend.follow.contains(friendUid) {
                isFollow = true
            }
            
            followCount = userFriend.followCount
            
            if userFriend.block.contains(friendUid) {
                isBlock = true
            }
        }
        
        if friendType == .follow {
            
        } else if friendType == .block {
            
        }
    }
    /// UserFriend追加/ 更新
    func addUserFriend(userFriend: UserFriendElement) async {
        // uid取得
        guard let uid = fetchUid() else { return }
        
        do {
            // 指定したUIDを持つドキュメントデータに追加（または更新）
            try db.collection(userFriendCollection).document(uid).setData(from: userFriend)
        } catch {
            print("Error adding/updating userFriend: \(error)")
        }
    }
    
    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// uidを指定してuserFriendDataを取得
    func fetchUserFriendData(uid: String) async -> UserFriendElement? {
        do {
            let document = try await db.collection(userFriendCollection).document(uid).getDocument()
            
            guard document.data() != nil else {
                print("Document does not exist")
                return nil
            }
            
            let decodedUserFriendData = try document.data(as: UserFriendElement.self)
            return decodedUserFriendData
        } catch {
            print("Error fetchUserFriendData: \(error)")
        }
        return nil
    }
}
