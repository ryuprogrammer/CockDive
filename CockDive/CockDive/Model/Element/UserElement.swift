import Foundation
import FirebaseFirestore

struct UserElement: Encodable, Decodable {
    @DocumentID var id: String?
    /// ニックネーム
    var nickName: String
    /// 自己紹介文
    var introduction: String?
    /// アイコン画像
    var iconImage: Data?
}

/// UserDefaults用
struct UserElementForUserDefaults: Encodable, Decodable {
    /// ニックネーム
    var nickName: String
    /// 自己紹介文
    var introduction: String?
    /// アイコン画像
    var iconImage: Data?
}
