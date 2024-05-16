import Foundation
import FirebaseFirestore

struct PostElement: Codable {
    @DocumentID var id: String?
    /// uid
    var uid: String
    /// 写真: 入力で必要
    var postImage: Data?
    /// 写真のURL: 取得で必要
    var postImageURL: String?
    /// ご飯のタイトル
    var title: String
    /// ご飯のメモ
    var memo: String?
    /// 公開設定
    var isPrivate: Bool
    /// 投稿日
    var createAt: Date
    /// いいねの数
    var likeCount: Int
    /// いいねしたユーザー
    var likedUser: [String]
    /// コメント
    var comment: [CommentElement]
}
