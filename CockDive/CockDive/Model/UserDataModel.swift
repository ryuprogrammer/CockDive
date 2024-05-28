import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserDataModel {
    /// コレクション名
    private let userCollection: String = "userData"
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    // MARK: - データ追加
    /// User追加/ 更新
    func addUser(user: UserElement) async {
        // uid取得
        guard let uid = fetchUid() else { return }
        
        do {
            // 指定したUIDを持つドキュメントデータに追加（または更新）
            try db.collection(userCollection).document(uid).setData(from: user)
            
            if let iconImage = user.iconImage {
                // storageに画像をアップロード
                await addUserIconImage(iconImage: iconImage, uid: uid)
            }
        } catch {
            print("Error adding/updating user: \(error)")
        }
    }
    
    /// iconImageを追加/ 更新
    func addUserIconImage(iconImage: Data, uid: String) async {
        // storageに画像をアップロード
        let storageRef = self.storage.reference()
        
        // iconImageのアップロード
        let iconImageRef = storageRef.child("iconImage/\(uid)/icon.jpg")
        
        do {
            _ = try await iconImageRef.putDataAsync(iconImage, metadata: nil)
        } catch {
            print("Error uploading icon image: \(error)")
        }
    }
    
    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// uidを指定してuserDataを取得: IconImage以外取得
    func fetchUserData(uid: String) async -> UserElement? {
        do {
            let document = try await db.collection(userCollection).document(uid).getDocument()
            
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
    
    /// uidを指定してiconImageを取得
    func fetchIconImage(uid: String) async -> Data? {
        let storageRef = self.storage.reference()
        let iconImageRef = storageRef.child("iconImage/\(uid)/icon.jpg")
        var iconData: Data?
        // アイコン画像をダウンロード
        iconImageRef.getData(maxSize: 10 * 1024 * 1024) { iconImageData, error in
            guard let iconImageData = iconImageData, error == nil else {
                return
            }
            iconData = iconImageData
        }
        
        return iconData
    }
}

// FirebaseStorageのputDataをasync/awaitで使えるように拡張
extension StorageReference {
    func putDataAsync(_ uploadData: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        return try await withCheckedThrowingContinuation { continuation in
            putData(uploadData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                }
            }
        }
    }
}
