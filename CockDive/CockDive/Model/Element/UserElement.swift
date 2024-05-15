import Foundation
import FirebaseFirestore

struct UserElement {
    @DocumentID var id: String?
    /// ニックネーム
    var nickName: String
    /// 自己紹介文
    var introduction: String?
    /// 投稿数
    var postCount: Int
    /// 投稿
    var posts: [PostElement]
    /// いいねした投稿数
    var likePostCount: Int
    /// いいねした投稿
    var likePost: [PostElement]
    /// フォロー数
    var followCount: Int
    /// フォロー
    var follow: [String]
    /// フォロワーの数
    var followerCount: Int
    /// フォロワー
    var follower: [String]
    /// ブロック
    var block: [String]
}
