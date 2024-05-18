import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct PostDataModel {
    /// コレクション名
    private let postDataCollection: String = "posts"
    /// Postを取得するリミット
    private let fetchPostLimit: Int = 20
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    // データを追加または更新
    enum AddType {
        case add
        case update
    }
    
    // MARK: - データ追加
    /// Post追加/ 更新
    func addPost(post: PostElement) async {
        // リファレンスを作成
        var docRef: DocumentReference = db.collection("posts").document()
        
        do {
            if let id = post.id { // idがある場合は、データの更新
                docRef = db.collection("posts").document(id)
            }
            
            var postWithId = post
            postWithId.id = docRef.documentID
            
            // Firestoreにデータを保存
            try docRef.setData(from: postWithId)
            
            if let postImage = post.postImage {
                // Storageに画像をアップロード
                if let postImageURL = await uploadPostImage(postImage: postImage, postId: docRef.documentID) {
                    // 画像のURLをFirestoreに更新
                    try await docRef.updateData(["postImageURL": postImageURL])
                }
            }
        } catch {
            print("Error adding post: \(error)")
        }
    }
    
    /// Like押す
    func changeLikeToPost(post: PostElement, uid: String) async {
        // Likeの数
        var likeCount = post.likeCount
        // LikeしたUser
        var likedUser = post.likedUser
        // いいねを押しているか判定
        if post.likedUser.contains(uid) { // ライクから削除
            likeCount -= 1
            likedUser.removeAll(where: {$0 == uid})
        } else { // ライクに追加
            likeCount += 1
            likedUser.append(uid)
        }
        
        guard let postId = post.id else { return }
        // リファレンス
        let docRef = db.collection("posts").document(postId)
        
        do {
            try await docRef.updateData(["likeCount": likeCount])
            try await docRef.updateData(["likedUser": likedUser])
        } catch {
            print("Error addHeartToPost: \(error)")
        }
    }
    
    /// Storageに画像をアップロード
    func uploadPostImage(postImage: Data, postId: String) async -> String? {
        let storageRef = Storage.storage().reference().child("postImages/\(postId)/post.jpg")
        
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
    
    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// Postを取得（件数指定）
    func fetchPostData() async -> [PostElement] {
        let docRef = db.collection(postDataCollection)
            .order(by: "createAt", descending: true)
            .limit(to: fetchPostLimit)
        var postData: [PostElement] = []
        
        do {
            let querySnapshot = try await docRef.getDocuments()
            for document in querySnapshot.documents {
                let result = try document.data(as: PostElement.self)
                postData.append(result)
            }
        } catch {
            print("Error getting documents: \(error)")
        }
        
        return postData
    }
    
    // TODO: データ取得できるか確認 - uidとcreateAtが違うからエラーかな、、、
    /// Postを取得（Uid/ 件数指定）
    func fetchPostFromUid(uid: String) async -> [PostElement] {
        let docRef = db.collection(postDataCollection)
            .whereField("uid", isEqualTo: uid)
            .order(by: "createAt", descending: true)
            .limit(to: fetchPostLimit)
        var postData: [PostElement] = []
        
        do {
            let querySnapshot = try await docRef.getDocuments()
            for document in querySnapshot.documents {
                let result = try document.data(as: PostElement.self)
                postData.append(result)
            }
        } catch {
            print("Error getting documents: \(error)")
        }
        
        return postData
    }
}
