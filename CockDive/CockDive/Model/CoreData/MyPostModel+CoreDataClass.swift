import Foundation
import CoreData

@objc(MyPostModel)
public class MyPostModel: NSManagedObject {
    // CRUD Operations
    static func fetchAll(context: NSManagedObjectContext) -> [MyPostModel] {
        let request: NSFetchRequest<MyPostModel> = MyPostModel.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch MyPostModel: \(error)")
            return []
        }
    }

    static func create(context: NSManagedObjectContext, title: String, memo: String, image: Data) {
        let newMyPost = MyPostModel(context: context)
        newMyPost.id = UUID().uuidString
        newMyPost.title = title
        newMyPost.memo = memo
        newMyPost.image = image
        newMyPost.createAt = Date()

        do {
            try context.save()
        } catch {
            print("Failed to create MyPostModel: \(error)")
        }
    }

    static func delete(_ myPost: MyPostModel, context: NSManagedObjectContext) {
        context.delete(myPost)
        do {
            try context.save()
        } catch {
            print("Failed to delete MyPostModel: \(error)")
        }
    }
}
