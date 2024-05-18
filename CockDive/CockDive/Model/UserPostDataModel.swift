import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserPostDataModel {
    /// コレクション名
    private let userPostCollection: String = "userPostData"
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    // MARK: - データ追加
    /// 自分のpostの追加/ 更新 または 友達の投稿をいいね
    func addPostId(postId: String, userPostType: UserPostType) async {
        // uid取得
        guard let uid = fetchUid() else { return }
        // 追加するデータ
        var newUserPostData = UserPostElement(id: uid, postCount: 0, posts: [], likePostCount: 0, likePost: [])
        
        // 以前のデータを取得
        if let userPostData = await fetchUserPostData(uid: uid) {
            newUserPostData = userPostData
            
            if userPostType == .post {
                // 投稿が存在→投稿を削除/ 投稿が存在しない→投稿を追加
                if newUserPostData.posts.contains(postId) {
                    newUserPostData.postCount -= 1
                    newUserPostData.posts.removeAll(where: {$0 == postId})
                } else {
                    newUserPostData.postCount += 1
                    newUserPostData.posts.append(postId)
                }
            } else if userPostType == .like {
                // いいねしている→いいねを削除/ いいねしていない→いいねを追加
                if newUserPostData.likePost.contains(postId) {
                    newUserPostData.likePostCount -= 1
                    newUserPostData.likePost.removeAll(where: {$0 == postId})
                } else {
                    newUserPostData.likePostCount += 1
                    newUserPostData.likePost.append(postId)
                }
            }
        } else { // データがないので追加
            if userPostType == .post {
                newUserPostData.postCount += 1
                newUserPostData.posts.append(postId)
            } else if userPostType == .like {
                newUserPostData.likePostCount += 1
                newUserPostData.likePost.append(postId)
            }
        }
        
        do {
            // 指定したUIDを持つドキュメントデータに追加（または更新）
            try db.collection(userPostCollection).document(uid).setData(from: newUserPostData)
        } catch {
            print("Error adding/updating user: \(error)")
        }
    }
    
    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// uidを指定してuserPostDataを取得
    func fetchUserPostData(uid: String) async -> UserPostElement? {
        do {
            let document = try await db.collection(userPostCollection).document(uid).getDocument()
            
            guard document.data() != nil else {
                print("Document does not exist")
                return nil
            }
            
            let decodedUserData = try document.data(as: UserPostElement.self)
            return decodedUserData
        } catch {
            print("Error fetching user data: \(error)")
        }
        return nil
    }
}
