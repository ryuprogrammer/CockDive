import Foundation
import FirebaseFirestore

struct UserFriendElement: Codable, Equatable {
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
    /// ブロックされてるUser
    var blockedByFriend: [String]
}

enum FriendType {
    case follow
    case block
}
