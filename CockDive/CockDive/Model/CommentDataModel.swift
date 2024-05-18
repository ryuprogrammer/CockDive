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
        let docRef = db.collection(postDataCollection).document(postId)
        
        do {
            try await docRef.updateData(["comment": newComment])
        } catch {
            print("Error addComment: \(error)")
        }
    }
    
    /// コメント削除
    func deleteComment(post: PostElement, deleteComment: CommentElement) async {
        // id取得
        guard let postId = post.id else { return }
        // 新しいコメント
        var newComment: [CommentElement] = post.comment
        // コメントを追加
        newComment.removeAll(where: {$0 == deleteComment})
        // リファレンスを作成
        let docRef = db.collection(postDataCollection).document(postId)
        
        do {
            try await docRef.updateData(["comment": newComment])
        } catch {
            print("Error deleteComment: \(error)")
        }
    }
}
