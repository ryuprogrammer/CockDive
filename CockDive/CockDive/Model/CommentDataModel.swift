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

        // 新しいコメントデータ
        var updatedComments = post.comment

        // 該当するコメントを削除
        updatedComments.removeAll { $0.id == commentToDelete.id }

        // 更新する投稿データ
        var updatedPost = post
        updatedPost.comment = updatedComments

        // リファレンスを作成
        let docRef = db.collection(postDataCollection).document(postId)

        do {
            // 更新した投稿データをエンコード
            let encodedPost = try Firestore.Encoder().encode(updatedPost)

            // 投稿データを更新
            docRef.setData(encodedPost) { error in
                if let error = error {
                    print("Error updating post: \(error)")
                } else {
                    print("Post successfully updated with deleted comment")
                }
            }
        } catch {
            print("Error encoding updatedPost: \(error)")
        }
    }
}
