import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct PostDataModel {
    /// コレクション名
    private let postDataCollection: String = "posts"
    /// Postを取得するリミット
    private let fetchPostLimit: Int = 5
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    // リスナーのリファレンスを保持するためのプロパティ
    var listeners: [ListenerRegistration] = []
    
    // データを追加または更新
    enum AddType {
        case add
        case update
    }
    
    // MARK: - データ追加
    /// Post追加/ 更新
    func addPost(post: PostElement) async {
        // リファレンスを作成
        var docRef: DocumentReference = db.collection(postDataCollection).document()
        
        do {
            if let id = post.id { // idがある場合は、データの更新
                docRef = db.collection(postDataCollection).document(id)
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
    func changeLikeToPost(post: PostElement) async {
        // 最新のPostを取得
        if let latestPost = await fetchPostFromPostId(postId: post.id ?? "") {
            guard let uid = fetchUid() else { return }
            
            // Likeの数
            var likeCount = latestPost.likeCount
            // LikeしたUser
            var likedUser = latestPost.likedUser
            // いいねを押しているか判定
            if latestPost.likedUser.contains(uid) { // ライクから削除
                likeCount -= 1
                likedUser.removeAll(where: {$0 == uid})
            } else { // ライクに追加
                likeCount += 1
                likedUser.append(uid)
            }
            
            guard let postId = post.id else { return }
            // リファレンス
            let docRef = db.collection(postDataCollection).document(postId)
            
            do {
                try await docRef.updateData(["likeCount": likeCount])
                try await docRef.updateData(["likedUser": likedUser])
            } catch {
                print("Error addHeartToPost: \(error)")
            }
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
    
    /// PostIdを件数指定して取得
    func fetchPostIdData() async -> [PostElement] {
        let docRef = db.collection(postDataCollection)
            .order(by: "createAt", descending: true)
            .limit(to: fetchPostLimit)
        var posts: [PostElement] = []
        
        do {
            let querySnapshot = try await docRef.getDocuments()
            for document in querySnapshot.documents {
                let decodedUserData = try document.data(as: PostElement.self)
                posts.append(decodedUserData)
            }
        } catch {
            print("Error getting documents: \(error)")
        }
        
        return posts
    }
    
    /// 最後に取得したドキュメントIDを基準にさらにPostIdを取得
    func fetchMorePostData(lastDocumentId: String?) async -> [PostElement] {
        var docRef = db.collection(postDataCollection)
            .order(by: "createAt", descending: true)
            .limit(to: fetchPostLimit)
        
        if let lastDocumentId = lastDocumentId {
            let lastDocumentSnapshot = try? await db.collection(postDataCollection).document(lastDocumentId).getDocument()
            if let lastDocument = lastDocumentSnapshot, lastDocument.exists {
                docRef = docRef.start(afterDocument: lastDocument)
            }
        }
        
        var posts: [PostElement] = []
        
        do {
            let querySnapshot = try await docRef.getDocuments()
            for document in querySnapshot.documents {
                let decodedUserData = try document.data(as: PostElement.self)
                posts.append(decodedUserData)
            }
        } catch {
            print("Error getting documents: \(error)")
        }
        
        return posts
    }
    
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
    
    /// postIdからPostDataを取得
    func fetchPostFromPostId(postId: String) async -> PostElement? {
        do {
            let document = try await db.collection(postDataCollection).document(postId).getDocument()
            
            guard document.data() != nil else {
                print("Document does not exist")
                return nil
            }
            
            let decodedUserData = try document.data(as: PostElement.self)
            
            return decodedUserData
        } catch {
            print("Error fetchPostFromPostId: \(error)")
        }
        return nil
    }
    
    // MARK: - データのリッスン
    
    // TODO: - 5/21の課題。
    // 「みんなのご飯」画面のタイムラインを実装完了←ノルマ
    // 「MyPage」画面のためにCoreDataの設定を始める←できたら
    /// PostIDを指定して、Postデータをリアルタイムリッスン
    /// 上のメソッドをこれに置き換えたい。
    /// 個々のCockCardViewでリスナーを持つ。
    /// つまり、CockCardViewModelで以下のメソッドを使用。
    func listenToPostData(postId: String, completion: @escaping (PostElement?) -> Void) -> ListenerRegistration {
        var postData: PostElement?
        let listener = db.collection(postDataCollection).document(postId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                completion(postData)
                return
            }
            do {
                postData = try document.data(as: PostElement.self)
                
                completion(postData)
            } catch {
                print("Error decoding post data: \(error)")
                completion(postData)
            }
        }
        
        return listener
    }
    
    /// リスナーを停止
    mutating func removeListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
}
