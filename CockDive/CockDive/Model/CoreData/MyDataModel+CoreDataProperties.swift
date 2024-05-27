import Foundation
import CoreData

extension MyDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyDataModel> {
        return NSFetchRequest<MyDataModel>(entityName: "MyDataModel")
    }

    @NSManaged public var followUids: NSObject?
    @NSManaged public var commentPostIds: NSObject?
}

extension MyDataModel: Identifiable {
}

extension MyDataModel {
    /// followUids→NSObject?型を[String]に変換
    public var wrappedFollowUids: [String] {
        get {
            return (followUids as? [String]) ?? []
        }
        set {
            followUids = newValue as NSObject
        }
    }

    /// commentPostIds→NSObject?型を[String]に変換
    public var wrappedCommentPostIds: [String] {
        get {
            return (commentPostIds as? [String]) ?? []
        }
        set {
            commentPostIds = newValue as NSObject
        }
    }
}
