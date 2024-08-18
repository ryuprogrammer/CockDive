import SwiftUI
import Foundation
import FirebaseFirestore

struct PostElement: Codable, Hashable, Equatable, Identifiable {
    @DocumentID var id: String?
    /// uid
    var uid: String
    /// 写真Data
    var postImage: Data?
    /// 写真URL
    var postImageURL: String?
    /// ご飯のタイトル
    var title: String
    /// ご飯のメモ
    var memo: String?
    /// 公開設定
    var isPrivate: Bool
    /// 投稿日
    var createAt: Date
    /// いいねの数
    var likeCount: Int
    /// いいねしたユーザー
    var likedUser: [String]
    /// コメント
    var comment: [CommentElement]
}

extension PostElement: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: { post in
            PostSharedContent(
                title: post.title,
                imageData: post.postImage,
                likeCount: post.likeCount
            )
        })
    }
}

struct PostSharedContent: Transferable {
    var title: String
    var imageData: Data?
    var likeCount: Int

    static var transferRepresentation: some TransferRepresentation {
        // 文字列と画像データを共有可能な形でエクスポート
        DataRepresentation(exportedContentType: .plainText) { sharedContent in
            let content = "\(sharedContent.title) - Likes: \(sharedContent.likeCount)"
            return content.data(using: .utf8) ?? Data()
        }

        DataRepresentation(exportedContentType: .image) { sharedContent in
            return sharedContent.imageData ?? Data()
        }
    }
}
