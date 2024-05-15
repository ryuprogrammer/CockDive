import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class PostDataModel {
    /// コレクション名
    private let postDataCollection: String = "postData"
    private let postCollection: String = "post"
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    // MARK: - データ追加
    /// Post追加
    func addPost(post: PostElement) async {
        // uid取得
        guard let uid = fetchUid() else { return }
        
        do {
            // 指定したUIDを持つドキュメントデータに追加（または更新）
            try db.collection(postDataCollection).document(uid).collection(postCollection).addDocument(from: post)
            
            if let postImage = post.postImage {
                // storageに画像をアップロード
                await addUserIconImage(postImage: postImage, uid: uid)
            }
        } catch {
            print("Error adding/updating user: \(error)")
        }
    }
    
    /// Post更新
    func updatePost(post: PostElement) async {
        
    }
    
    /// iconImageを追加/ 更新
    func addUserIconImage(postImage: Data, uid: String) async {
        // storageに画像をアップロード
        let storageRef = self.storage.reference()
        
        // iconImageのアップロード
        let PostImageRef = storageRef.child("postImage/\(uid)/icon.jpg")
        
        do {
            _ = try await PostImageRef.putDataAsync(postImage, metadata: nil)
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
    func fetchPostData(uid: String) async -> UserElement? {
        do {
            let document = try await db.collection(postDataCollection).document(uid).getDocument()
            
            guard let data = document.data() else {
                print("Document does not exist")
                return nil
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let decoder = JSONDecoder()
            let decodedUserData = try decoder.decode(UserElement.self, from: jsonData)
            
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
