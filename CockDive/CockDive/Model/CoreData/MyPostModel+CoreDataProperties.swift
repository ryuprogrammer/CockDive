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

extension MyPostModel {
    public var wrappedId: String { id ?? "" }
    public var wrappedImage: Data { image ?? Data() }
    public var wrappedTitle: String { title ?? "" }
    public var wrappedMemo: String { memo ?? "" }
    public var wrappedCreateAt: Date { createAt ?? Date() }
}
