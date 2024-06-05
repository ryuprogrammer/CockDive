import CoreData

class LikePostCoreDataManager {
    static let shared = LikePostCoreDataManager()

    private init() {}

    var context: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }

    // MARK: - データの存在確認

    /// 指定されたIDのLikePostModelが存在するかどうかをチェックする
    /// - Parameter id: チェックするLikePostModelのID
    /// - Returns: 存在する場合はtrue、存在しない場合はfalse
    func checkIsLike(id: String) -> Bool {
        return fetchById(id: id) != nil
    }

    // MARK: - データの存在確認と追加/削除

    /// 指定されたIDのLikePostModelが存在するなら削除、存在しないなら追加する
    /// - Parameters:
    ///   - id: LikePostModelのID
    ///   - toLike: ライクするかどうかのフラグ
    func toggleLikePost(id: String, toLike: Bool) {
        if let likePost = fetchById(id: id) {
            if !toLike {
                delete(likePost)
            }
        } else {
            if toLike {
                create(id: id, createAt: Date())
            }
        }
    }

    // MARK: - データの取得

    /// 全てのLikePostModelを取得する
    /// - Returns: LikePostModelの配列
    func fetchAllLikePost() -> [LikePostModel] {
        let request: NSFetchRequest<LikePostModel> = LikePostModel.fetchRequest()

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch LikePostModel: \(error)")
            return []
        }
    }

    /// 指定されたIDのLikePostModelを取得する
    /// - Parameter id: 取得するLikePostModelのID
    /// - Returns: 指定されたIDのLikePostModel、存在しない場合はnil
    private func fetchById(id: String) -> LikePostModel? {
        let request: NSFetchRequest<LikePostModel> = LikePostModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch LikePostModel by id: \(error)")
            return nil
        }
    }

    // MARK: - データの追加

    /// 新しいLikePostModelを作成する
    /// - Parameters:
    ///   - id: LikePostModelのID
    ///   - createAt: 作成日
    private func create(id: String, createAt: Date) {
        if fetchById(id: id) == nil {
            let newLikePost = LikePostModel(context: context)
            newLikePost.id = id
            newLikePost.createAt = createAt

            do {
                try context.save()
            } catch {
                print("Failed to create LikePostModel: \(error)")
            }
        } else {
            print("LikePostModel with id \(id) already exists.")
        }
    }

    // MARK: - データの削除

    /// LikePostModelを削除する
    /// - Parameter likePost: 削除するLikePostModel
    private func delete(_ likePost: LikePostModel) {
        context.delete(likePost)
        do {
            try context.save()
        } catch {
            print("Failed to delete LikePostModel: \(error)")
        }
    }

    /// すべてのLikePostModelを削除する
    func deleteAllLikedPosts() {
        let request: NSFetchRequest<LikePostModel> = LikePostModel.fetchRequest()
        do {
            let results = try context.fetch(request)
            for post in results {
                context.delete(post)
            }
            try context.save()
        } catch {
            print("Failed to delete all LikePostModel: \(error)")
        }
    }

}
