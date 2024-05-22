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
