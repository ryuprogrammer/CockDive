import Foundation
import FirebaseFirestore

struct UserElement: Encodable, Decodable {
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
struct UserElementForUserDefaults: Encodable, Decodable {
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
    /// 登録が必要
    case registrationRequired
    /// 通常のユーザー
    case normalUser
    /// 垢BANされたユーザー
    case bannedUser
    /// Loading中
    case loading
}
