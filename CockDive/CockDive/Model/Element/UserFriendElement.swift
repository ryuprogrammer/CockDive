import Foundation
import FirebaseFirestore

struct UserFriendElement {
    @DocumentID var id: String?
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
