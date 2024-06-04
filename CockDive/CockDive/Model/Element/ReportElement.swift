import Foundation
import FirebaseFirestore

struct ReportElement: Identifiable, Codable {
    @DocumentID var id: String?
    /// 通報されたユーザーのID
    var reportedUserID: String
    /// 通報したユーザーのID
    var reportingUserID: String
    /// 通報理由
    var reason: String
    /// 通報日時
    var createAt: Date
    /// 通報対象の投稿ID（オプション）
    var postID: String?
}
