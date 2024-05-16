import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct PostDataModel {
    /// コレクション名
    private let postDataCollection: String = "postData"
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
    
    /// Storageに画像をアップロード
    func uploadPostImage(postImage: Data, postId: String) async -> String? {
        let storageRef = Storage.storage().reference().child("postImages/\(postId)/icon.jpg")
        
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
        print("データ取得スタート")
        // 日付順に並び替えて取得
        let docRef = db.collection(postDataCollection)
//            .order(by: "createAt", descending: true)
//            .limit(to: fetchPostLimit)
        var postData: [PostElement] = []
        let decoder = JSONDecoder()
        
        do {
            let querySnapshot = try await docRef.getDocuments()
            print("querySnapshot: \(querySnapshot)")
            print("querySnapshot.count: \(querySnapshot.count)")
            for document in querySnapshot.documents {
                print("docment: \(document)")
                let data = document.data()
                print("data: \(data)")
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                print("jsonData: \(jsonData)")
                let decodedPost = try decoder.decode(PostElement.self, from: jsonData)
                print("decodedPost \(decodedPost)")
                postData.append(decodedPost)
                print("postData: \(postData)")
            }
        } catch {
            print("Error getting documents: \(error)")
        }
        
        return postData
    }
    
    // TODO: データ取得できるか確認 - uidとcreateAtが違うからエラーかな、、、
    /// Postを取得（Uid/ 件数指定）
    func fetchPostFromUid(uid: String) async -> [PostElement] {
        // 日付順に並び替えて、Uidを指定して取得
        let docRef = db.collection(postDataCollection)
            .whereField("uid", isEqualTo: uid)
            // ↓これがuidのフィールドでないためエラー出るかも: https://firebase.google.com/docs/firestore/query-data/order-limit-data?hl=ja&_gl=1*ralp11*_up*MQ..*_ga*MTMzNDU2NjA1MS4xNzE1ODI4MDU4*_ga_CW55HF8NVT*MTcxNTgyODA1Ny4xLjAuMTcxNTgyODA1Ny4wLjAuMA..#limitations
            .order(by: "createAt", descending: true)
            .limit(to: fetchPostLimit)
        var postData: [PostElement] = []
        let decoder = JSONDecoder()
        
        do {
            let querySnapshot = try await docRef.getDocuments()
            for document in querySnapshot.documents {
                let data = document.data()
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let decodedPost = try decoder.decode(PostElement.self, from: jsonData)
                postData.append(decodedPost)
            }
        } catch {
            print("Error getting documents: \(error)")
        }
        
        return postData
    }
}
