import CoreData

class MyPostCoreDataManager {
    static let shared = MyPostCoreDataManager()

    private init() {}

    var context: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }

    // MARK: - データの取得

    /// 全てのMyPostModelを取得する
    func fetchAll() -> [MyPostModel] {
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
    func create(
        id: String,
        createAt: Date,
        title: String,
        memo: String,
        image: Data
    ) {
        let newMyPost = MyPostModel(context: context)
        newMyPost.id = id
        newMyPost.title = title
        newMyPost.memo = memo
        newMyPost.image = image
        newMyPost.createAt = createAt

        do {
            try context.save()
        } catch {
            print("Failed to create MyPostModel: \(error)")
        }
    }

    // MARK: - データの削除

    /// 指定されたMyPostModelを削除する
    func delete(myPost: MyPostModel) {
        context.delete(myPost)
        do {
            try context.save()
        } catch {
            print("Failed to delete MyPostModel: \(error)")
        }
    }
}
