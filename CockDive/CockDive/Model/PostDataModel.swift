import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

/*
 メソッド目次:
 1. createNewDocId() - 新しいドキュメントIDを作成する。
 2. addPost(post:newDocId:) - 新しい投稿を追加または既存の投稿を更新する。
 3. changeLikeToPost(post:toLike:) - 投稿の「いいね」状態を変更する。
 4. uploadPostImage(postImage:postId:) - 画像をFirebase Storageにアップロードする。
 5. fetchUid() - 現在のユーザーのUIDを取得する。
 6. fetchPostIdData() - 投稿IDを指定した件数だけ取得する。
 7. fetchMorePostData(lastDocumentId:completion:) - 最後に取得したドキュメントIDを基準にさらに投稿を取得する。
 8. fetchPostFromUid(uid:) - 指定したUIDの投稿を取得する。
 9. fetchMorePostDataFromUid(uid:lastDocumentId:completion:) - 指定したUIDの最後に取得したドキュメントIDを基準にさらに投稿を取得する。
 10. fetchPostFromPostId(postId:) - 指定した投稿IDから投稿データを取得する。
 11. listenToPostData(postId:completion:) - 指定した投稿IDの投稿データをリッスンする。
 12. removeListeners() - すべてのリスナーを停止する。
 13. fetchPostsFromUids(uids:) - 複数のUIDを指定して投稿を取得する。
 14. fetchMorePostsFromUids(uids:lastDocumentId:completion:) - 複数のUIDを指定して、最後に取得したドキュメントIDを基準にさらに投稿を取得する。
 15. fetchLimitedPostsFromDocumentIds(documentIdsWithDates:) - 複数のドキュメントIDと日付を指定して投稿を取得し、CreateAt順で並べる。
 */

struct PostDataModel {
    /// コレクション名
    private let postDataCollection: String = "posts"
    /// Postを取得するリミット
    private let fetchPostLimit: Int = 10
    private let maxDocSize = 1000000
    private var db = Firestore.firestore()
    private var storage = Storage.storage()

    // リスナーのリファレンスを保持するためのプロパティ
    var listeners: [ListenerRegistration] = []

    // データを追加または更新
    enum AddType {
        case add
        case update
    }

    /// 新しいリファレンス作成
    func createNewDocId() -> String {
        return db.collection(postDataCollection).document().documentID
    }

    // MARK: - データ追加
    /// Post追加
    func addPost(post: PostElement, completion: @escaping (Result<String, Error>) -> Void) {
        var docId: String {
            if let postId = post.id {
                return postId
            } else {
                let docRef = db.collection(postDataCollection).document()
                return docRef.documentID
            }
        }

        let finalDocRef = db.collection(postDataCollection).document(docId)
        var postWithId = post
        postWithId.id = finalDocRef.documentID

        savePostData(post: postWithId, docRef: finalDocRef) { result in
            switch result {
            case .success:
                if let postImage = postWithId.postImage {
                    self.uploadPostImage(postImage: postImage, postId: finalDocRef.documentID) { result in
                        switch result {
                        case .success(let postImageURL):
                            self.updatePostImageURL(docRef: finalDocRef, postImageURL: postImageURL) { result in
                                switch result {
                                case .success:
                                    completion(.success(finalDocRef.documentID))
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.success(finalDocRef.documentID))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Postデータを保存
    private func savePostData(post: PostElement, docRef: DocumentReference, completion: @escaping (Result<Void, Error>) -> Void) {
        var postData = post
        // MARK: 画像サイズが大きい場合はnilにする
        if let imageDataSize = post.postImage?.count {
            if imageDataSize > maxDocSize {
                // 画像サイズが大きいのでnilにする
                postData.postImage = nil
            }
        }

        do {
            try docRef.setData(from: postData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    /// PostImageURLを更新
    private func updatePostImageURL(docRef: DocumentReference, postImageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        docRef.updateData(["postImageURL": postImageURL]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    /// Storageに画像をアップロード
    func uploadPostImage(postImage: Data, postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("postImages/\(postId)/post.jpg")

        storageRef.putData(postImage, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let downloadURL = url {
                    completion(.success(downloadURL.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "DownloadURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL."])))
                }
            }
        }
    }

    /// Like押す
    func changeLikeToPost(
        post: PostElement,
        toLike: Bool
    ) async {
        // 最新のPostを取得
        if let latestPost = await fetchPostFromPostId(postId: post.id ?? "") {
            guard let uid = fetchUid() else { return }

            // Likeの数
            var likeCount = latestPost.likeCount
            // LikeしたUser
            var likedUser = latestPost.likedUser
            // firestoreのLike情報
            let isLikeAtFirestore = latestPost.likedUser.contains(uid)

            // 更新したいライク（toLike）とforestoreが異なる場合のみ更新
            if toLike != isLikeAtFirestore {
                // toLikeによって変更
                if toLike {
                    likeCount += 1
                    likedUser.append(uid)
                } else {
                    likeCount -= 1
                    likedUser.removeAll(where: {$0 == uid})
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
    func fetchMorePostData(lastDocumentId: String?, completion: @escaping (Result<[PostElement], Error>) -> Void) async {
        var docRef = db.collection(postDataCollection)
            .order(by: "createAt", descending: true)
            .limit(to: fetchPostLimit)

        if let lastDocumentId = lastDocumentId, !lastDocumentId.isEmpty {
            let lastDocumentSnapshot = try? await db.collection(postDataCollection).document(lastDocumentId).getDocument()
            if let lastDocument = lastDocumentSnapshot, lastDocument.exists {
                docRef = docRef.start(afterDocument: lastDocument)
            } else {
                print("The document with ID \(lastDocumentId) does not exist or could not be fetched.")
                completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "The document with ID \(lastDocumentId) does not exist or could not be fetched."])))
                return
            }
        }

        var posts: [PostElement] = []

        do {
            let querySnapshot = try await docRef.getDocuments()
            for document in querySnapshot.documents {
                let decodedUserData = try document.data(as: PostElement.self)
                posts.append(decodedUserData)
            }
            completion(.success(posts))
        } catch {
            completion(.failure(error))
            print("Error getting documents: \(error)")
        }
    }

    /// Postを取得（Uid/ 件数指定）（ユーザー指定）
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

    /// 最後に取得したドキュメントIDを基準にさらにPostIdを取得（ユーザー指定）
    func fetchMorePostDataFromUid(uid: String, lastDocumentId: String?, completion: @escaping (Result<[PostElement], Error>) -> Void) async {
        var docRef = db.collection(postDataCollection)
            .whereField("uid", isEqualTo: uid)
            .order(by: "createAt", descending: true)
            .limit(to: fetchPostLimit)

        if let lastDocumentId = lastDocumentId, !lastDocumentId.isEmpty {
            do {
                let lastDocumentSnapshot = try await db.collection(postDataCollection).document(lastDocumentId).getDocument()
                if lastDocumentSnapshot.exists {
                    docRef = docRef.start(afterDocument: lastDocumentSnapshot)
                } else {
                    print("The document with ID \(lastDocumentId) does not exist or could not be fetched.")
                    completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "The document with ID \(lastDocumentId) does not exist or could not be fetched."])))
                    return
                }
            } catch {
                print("Error fetching last document: \(error)")
                completion(.failure(error))
                return
            }
        }

        var posts: [PostElement] = []

        do {
            let querySnapshot = try await docRef.getDocuments()
            for document in querySnapshot.documents {
                let decodedUserData = try document.data(as: PostElement.self)
                posts.append(decodedUserData)
            }
            completion(.success(posts))  // 成功時にデータをコールバック
        } catch {
            completion(.failure(error))  // エラー時にエラーをコールバック
            print("Error getting documents: \(error)")
        }
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

    /// 複数のUIDを指定して投稿を取得
    func fetchPostsFromUids(uids: [String]) async -> [PostElement] {
        let docRef = db.collection(postDataCollection)
            .whereField("uid", in: uids)
            .order(by: "createAt", descending: true)
            .limit(to: fetchPostLimit)
        var posts: [PostElement] = []

        do {
            let querySnapshot = try await docRef.getDocuments()
            for document in querySnapshot.documents {
                let result = try document.data(as: PostElement.self)
                posts.append(result)
            }
        } catch {
            print("Error getting documents: \(error)")
        }

        return posts
    }

    /// 複数のUIDを指定してさらに投稿を取得
    func fetchMorePostsFromUids(uids: [String], lastDocumentId: String?, completion: @escaping (Result<[PostElement], Error>) -> Void) async {
        var docRef = db.collection(postDataCollection)
            .whereField("uid", in: uids)
            .order(by: "createAt", descending: true)
            .limit(to: fetchPostLimit)

        if let lastDocumentId = lastDocumentId, !lastDocumentId.isEmpty {
            do {
                let lastDocumentSnapshot = try await db.collection(postDataCollection).document(lastDocumentId).getDocument()
                if lastDocumentSnapshot.exists {
                    docRef = docRef.start(afterDocument: lastDocumentSnapshot)
                } else {
                    print("The document with ID \(lastDocumentId) does not exist or could not be fetched.")
                    completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "The document with ID \(lastDocumentId) does not exist or could not be fetched."])))
                    return
                }
            } catch {
                print("Error fetching last document: \(error)")
                completion(.failure(error))
                return
            }
        }

        var posts: [PostElement] = []

        do {
            let querySnapshot = try await docRef.getDocuments()
            for document in querySnapshot.documents {
                let decodedUserData = try document.data(as: PostElement.self)
                posts.append(decodedUserData)
            }
            completion(.success(posts))  // 成功時にデータをコールバック
        } catch {
            completion(.failure(error))  // エラー時にエラーをコールバック
            print("Error getting documents: \(error)")
        }
    }

    /// 複数のLikePostModelを指定して投稿を取得し、CreateAt順で並べる
    /// - Parameter likePosts: LikePostModelの配列
    /// - Returns: (posts: PostElementの配列, remainingLikePosts: LikePostModelの配列)
    func fetchLimitedPostsFromLikePosts(
        likePosts: [LikePostModel]
    ) async -> (
        posts: [PostElement],
        remainingLikePosts: [LikePostModel]
    ) {
        var posts: [PostElement] = []
        var remainingLikePosts: [LikePostModel] = []

        // 日付順にソート
        let sortedLikePosts = likePosts.sorted { $0.wrappedCreateAt > $1.wrappedCreateAt }

        // LikePostModelごとにPostElementを取得
        for likePost in sortedLikePosts {
            if let post = await fetchPostFromPostId(postId: likePost.wrappedId) {
                posts.append(post)
            }
            if posts.count >= fetchPostLimit {
                remainingLikePosts = Array(sortedLikePosts.dropFirst(posts.count))
                break
            }
        }

        return (posts, remainingLikePosts)
    }

    // MARK: - データのリッスン

    /// idを指定して投稿をリッスン
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
