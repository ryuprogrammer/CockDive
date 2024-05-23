import Foundation
import CoreData

@objc(MyDataModel)
public class MyDataModel: NSManagedObject {
    // CRUD Operations
    static func fetchAll(context: NSManagedObjectContext) -> [MyDataModel] {
        let request: NSFetchRequest<MyDataModel> = MyDataModel.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch MyDataModel: \(error)")
            return []
        }
    }
    
    static func create(context: NSManagedObjectContext) {
        let newMyData = MyDataModel(context: context)
        newMyData.followUids = [] as NSObject
        newMyData.likePostIds = [] as NSObject
        newMyData.commentPostIds = [] as NSObject

        do {
            try context.save()
        } catch {
            print("Failed to create MyDataModel: \(error)")
        }
    }

    static func delete(_ myData: MyDataModel, context: NSManagedObjectContext) {
        context.delete(myData)
        do {
            try context.save()
        } catch {
            print("Failed to delete MyDataModel: \(error)")
        }
    }
}
