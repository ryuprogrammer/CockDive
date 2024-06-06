import Foundation

struct CommentElement: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()
    /// uid
    var uid: String
    /// コメント内容
    var comment: String
    /// 投稿日
    var createAt: Date
}
