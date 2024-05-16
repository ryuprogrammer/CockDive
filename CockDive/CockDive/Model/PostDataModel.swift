import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class PostDataModel {
    /// コレクション名
    private let postDataCollection: String = "postData"
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    // MARK: - データ追加
    /// Post追加
    func addPost(post: PostElement) async {
        // uid取得
        guard let uid = fetchUid() else { return }
        
        do {
            // ドキュメントIDを生成
            let newDocRef = db.collection("users").document(uid).collection("posts").document()
            
            var postWithId = post
            postWithId.id = newDocRef.documentID
            
            // Firestoreにデータを保存
            try newDocRef.setData(from: postWithId)
            
            if let postImage = post.postImage {
                // Storageに画像をアップロード
                if let postImageURL = await uploadPostImage(postImage: postImage, uid: uid, postId: newDocRef.documentID) {
                    // 画像のURLをFirestoreに更新
                    try await newDocRef.updateData(["postImageURL": postImageURL])
                }
            }
        } catch {
            print("Error adding post: \(error)")
        }
    }
    
    /// Storageに画像をアップロード
    func uploadPostImage(postImage: Data, uid: String, postId: String) async -> String? {
        let storageRef = Storage.storage().reference().child("postImages/\(uid)/\(postId)/icon.jpg")
        
        do {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = try await storageRef.putDataAsync(postImage, metadata: metadata)
            
            // 画像のダウンロードURLを取得
            let downloadURL = try await storageRef.downloadURL()
            
            return downloadURL.absoluteString
        } catch {
            print("Error uploading post image: \(error)")
            return nil
        }
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
