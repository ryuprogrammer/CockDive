import Foundation
import CoreData


extension MyDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyDataModel> {
        return NSFetchRequest<MyDataModel>(entityName: "MyDataModel")
    }

    @NSManaged public var followUids: NSObject?
    @NSManaged public var likePostIds: NSObject?
    @NSManaged public var commentPostIds: NSObject?

}

extension MyDataModel : Identifiable {

}

extension MyDataModel {
    /// followUids→NSObject?型を[String]に変換
    public var wrappedFollowUids: [String] {
        if let followUids,
           let followUidsStr = followUids as? [String] {
            return followUidsStr
        }

        return []
    }

    /// likePostIds→NSObject?型を[String]に変換
    public var wrappedLikePostIds: [String] {
        if let likePostIds,
           let likePostIdsStr = likePostIds as? [String] {
            return likePostIdsStr
        }

        return []
    }

    /// commentPostIds→NSObject?型を[String]に変換
    public var wrappedCommentPostIds: [String] {
        if let commentPostIds,
           let commentPostIdsStr = commentPostIds as? [String] {
            return commentPostIdsStr
        }

        return []
    }
}
