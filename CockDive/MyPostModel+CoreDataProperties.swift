import Foundation
import CoreData


extension MyPostModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyPostModel> {
        return NSFetchRequest<MyPostModel>(entityName: "MyPostModel")
    }

    @NSManaged public var id: String?
    @NSManaged public var image: Data?
    @NSManaged public var title: String?
    @NSManaged public var memo: String?
    @NSManaged public var createAt: Date?

}

extension MyPostModel : Identifiable {

}
