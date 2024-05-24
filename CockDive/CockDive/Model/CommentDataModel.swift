import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CommentDataModel {
    /// コレクション名
    private let postDataCollection: String = "posts"
    private var db = Firestore.firestore()
    
    // MARK: - データ追加
    /// コメント更新（追加/ 削除）
    func updateComment(post: PostElement, newComment: CommentElement) {
        // id取得
        guard let postId = post.id else { return }
        // リファレンスを作成
        let docRef = db.collection(postDataCollection).document(postId)
        var newPost = post
        newPost.comment.append(newComment)
        
        do {
            try docRef.setData(from: newPost)
        } catch {
            print("Error addComment: \(error)")
        }
    }
}
