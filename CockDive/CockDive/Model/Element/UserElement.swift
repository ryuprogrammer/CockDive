import Foundation
import FirebaseFirestore

struct UserElement: Encodable, Decodable, Equatable, Hashable {
    @DocumentID var id: String?
    /// ニックネーム
    var nickName: String
    /// 自己紹介文
    var introduction: String?
    /// アイコン画像: 入力で必要
    var iconImage: Data?
    /// アイコンのURL: 取得で必要
    var iconURL: String?
}

/// UserDefaults用
struct UserElementForUserDefaults: Encodable, Decodable, Equatable {
    /// ニックネーム
    var nickName: String
    /// 自己紹介文
    var introduction: String?
    /// アイコン画像: 入力で必要
    var iconImage: Data?
    /// アイコンのURL: 取得で必要
    var iconURL: String?
}

/// UserStatus
enum UserStatus {
    /// SingInが必要
    case signInRequired
    /// 名前の登録が必要
    case nameRegistrationRequired
    /// アイコン写真の登録が必要
    case iconRegistrationRequired
    /// 通常のユーザー
    case normalUser
    /// 垢BANされたユーザー
    case bannedUser
    /// Loading中
    case loading
}

enum UserUpdateStatus: Equatable {
    case idle
    case loading
    case success(String)
    case error(String)
}
