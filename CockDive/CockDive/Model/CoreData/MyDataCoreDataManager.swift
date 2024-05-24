import CoreData

class MyDataCoreDataManager {
    static let shared = MyDataCoreDataManager()

    private init() {}

    var context: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }

    func createMyDataModel() -> MyDataModel? {
        guard let entity = NSEntityDescription.entity(forEntityName: "MyDataModel", in: context) else {
            print("MyDataModelのエンティティが見つかりません")
            return nil
        }
        let myDataModel = MyDataModel(entity: entity, insertInto: context)
        return myDataModel
    }

    func fetchMyDataModels() -> [MyDataModel] {
        let request: NSFetchRequest<MyDataModel> = MyDataModel.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("MyDataModelの取得に失敗しました: \(error)")
            return []
        }
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("コンテキストの保存に失敗しました: \(error)")
            }
        }
    }

    // MARK: - データの判定

    // フォロー状態を判定する
    func checkIsFollow(uid: String) -> Bool {
        let myDataModel = fetchMyDataModels().first ?? createMyDataModel()
        return myDataModel?.wrappedFollowUids.contains(uid) ?? false
    }

    // いいね状態を判定する
    func checkIsLike(postId: String) -> Bool {
        let myDataModel = fetchMyDataModels().first ?? createMyDataModel()
        return myDataModel?.wrappedLikePostIds.contains(postId) ?? false
    }

    // MARK: - データの変更

    // フォロー状態を変更する
    func changeFollow(uid: String) {
        if checkIsFollow(uid: uid) {
            removeFollowUid(uid: uid)
        } else {
            addFollowUid(uid: uid)
        }
    }

    // いいね状態を変更する
    func changeLike(postId: String, toLike: Bool) {
        let beforeLike = checkIsLike(postId: postId)
        if toLike != beforeLike {
            if toLike {
                addLikePostId(postId: postId)
            } else {
                removeLikePostId(postId: postId)
            }
        }
    }

    // MARK: - データの追加

    // フォローUIDを追加する
    func addFollowUid(uid: String) {
        let myDataModel = fetchMyDataModels().first ?? createMyDataModel()
        var uids = myDataModel?.wrappedFollowUids ?? []
        uids.append(uid)
        myDataModel?.followUids = uids as NSObject

        saveContext()
    }

    // いいねポストIDを追加する
    func addLikePostId(postId: String) {
        let myDataModel = fetchMyDataModels().first ?? createMyDataModel()
        var postIds = myDataModel?.wrappedLikePostIds ?? []
        postIds.append(postId)
        myDataModel?.likePostIds = postIds as NSObject

        saveContext()
    }

    // コメントポストIDを追加する
    func addCommentPostId(postId: String) {
        let myDataModel = fetchMyDataModels().first ?? createMyDataModel()
        var postIds = myDataModel?.wrappedCommentPostIds ?? []
        postIds.append(postId)
        myDataModel?.commentPostIds = postIds as NSObject

        saveContext()
    }

    // MARK: - データの削除

    // フォローUIDを削除する
    func removeFollowUid(uid: String) {
        let myDataModel = fetchMyDataModels().first ?? createMyDataModel()
        var uids = myDataModel?.wrappedFollowUids ?? []
        if let index = uids.firstIndex(of: uid) {
            uids.remove(at: index)
        }
        myDataModel?.followUids = uids as NSObject

        saveContext()
    }

    // いいねポストIDを削除する
    func removeLikePostId(postId: String) {
        let myDataModel = fetchMyDataModels().first ?? createMyDataModel()
        var postIds = myDataModel?.wrappedLikePostIds ?? []
        if let index = postIds.firstIndex(of: postId) {
            postIds.remove(at: index)
        }
        myDataModel?.likePostIds = postIds as NSObject

        saveContext()
    }

    // コメントポストIDを削除する
    func removeCommentPostId(postId: String) {
        let myDataModel = fetchMyDataModels().first ?? createMyDataModel()
        var postIds = myDataModel?.wrappedCommentPostIds ?? []
        if let index = postIds.firstIndex(of: postId) {
            postIds.remove(at: index)
        }
        myDataModel?.commentPostIds = postIds as NSObject

        saveContext()
    }
}
