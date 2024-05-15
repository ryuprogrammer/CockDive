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
    /// フォロー数
    var followCount: Int
    /// フォロワーの数
    var followerCount: Int
}
