import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CommentDataModel {
    /// コレクション名
    private let postDataCollection: String = "posts"
    private var db = Firestore.firestore()

    // MARK: - データ追加
    /// コメント更新（追加）
    func updateComment(post: PostElement, newComment: CommentElement) {
        // id取得
        guard let postId = post.id else { return }

        // リファレンスを作成
        let docRef = db.collection(postDataCollection).document(postId)

        do {
            // newCommentをエンコード
            let encodedComment = try Firestore.Encoder().encode(newComment)

            // コメントフィールドを更新
            docRef.updateData([
                "comment": FieldValue.arrayUnion([encodedComment])
            ]) { error in
                if let error = error {
                    print("Error updating comment: \(error)")
                } else {
                    print("Comment successfully updated")
                }
            }
        } catch {
            print("Error encoding newComment: \(error)")
        }
    }

    // MARK: - データ削除
    /// コメント削除
    func deleteComment(post: PostElement, commentToDelete: CommentElement) {
        // id取得
        guard let postId = post.id else { return }

        // リファレンスを作成
        let docRef = db.collection(postDataCollection).document(postId)

        do {
            // commentToDeleteをエンコード
            let encodedComment = try Firestore.Encoder().encode(commentToDelete)

            // コメントフィールドから削除
            docRef.updateData([
                "comment": FieldValue.arrayRemove([encodedComment])
            ]) { error in
                if let error = error {
                    print("Error deleting comment: \(error)")
                } else {
                    print("Comment successfully deleted")
                }
            }
        } catch {
            print("Error encoding commentToDelete: \(error)")
        }
    }
}
