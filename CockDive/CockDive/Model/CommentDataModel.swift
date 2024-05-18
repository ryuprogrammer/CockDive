import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CommentDataModel {
    /// コレクション名
    private let postDataCollection: String = "posts"
    /// Postを取得するリミット
    private let fetchPostLimit: Int = 20
    private var db = Firestore.firestore()
    
    // MARK: - データ追加
    /// コメント追加
    func addComment(post: PostElement, comment: CommentElement) async {
        // id取得
        guard let postId = post.id else { return }
        // 新しいコメント
        var newComment: [CommentElement] = post.comment
        // コメントを追加
        newComment.append(comment)
        // リファレンスを作成
        var docRef = db.collection(postDataCollection).document(postId)
        
        do {
            try await docRef.updateData(["comment": newComment])
        } catch {
            print("Error addComment: \(error)")
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
}
