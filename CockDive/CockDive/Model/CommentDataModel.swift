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
    /// コメント更新（追加/ 削除）
    func updateComment(post: PostElement, newComments: [CommentElement]) {
        // id取得
        guard let postId = post.id else { return }
        // リファレンスを作成
        let docRef = db.collection(postDataCollection).document(postId)
        var newPost = post
        newPost.comment = newComments
        
        do {
            try docRef.setData(from: newPost)
        } catch {
            print("Error addComment: \(error)")
        }
    }
}
