import Foundation
import FirebaseFirestore

struct UserPostElement: Codable {
    @DocumentID var id: String?
    /// 投稿数
    var postCount: Int
    /// 投稿: idを保存
    var posts: [String]
    /// いいねした投稿数
    var likePostCount: Int
    /// いいねした投稿
    var likePost: [String]
}

enum UserPostType {
    case post
    case like
}
