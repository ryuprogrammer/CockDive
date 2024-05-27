import Foundation
import CoreData

extension LikePostModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikePostModel> {
        return NSFetchRequest<LikePostModel>(entityName: "LikePostModel")
    }

    @NSManaged public var id: String?
    @NSManaged public var createAt: Date?
}

extension LikePostModel: Identifiable {}

extension LikePostModel {
    public var wrappedId: String { id ?? "" }
    public var wrappedCreateAt: Date { createAt ?? Date() }
}
