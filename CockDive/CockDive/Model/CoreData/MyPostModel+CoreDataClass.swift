import Foundation
import CoreData

@objc(MyPostModel)
public class MyPostModel: NSManagedObject {
    // MARK: - データの取得

    /// 全てのMyPostModelを取得する
    static func fetchAll(context: NSManagedObjectContext) -> [MyPostModel] {
        let request: NSFetchRequest<MyPostModel> = MyPostModel.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch MyPostModel: \(error)")
            return []
        }
    }

    // MARK: - データの追加

    /// 新しいMyPostModelを作成する
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

    // MARK: - データの削除

    /// 指定されたMyPostModelを削除する
    static func delete(_ myPost: MyPostModel, context: NSManagedObjectContext) {
        context.delete(myPost)
        do {
            try context.save()
        } catch {
            print("Failed to delete MyPostModel: \(error)")
        }
    }
}
