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
        guard let myDataModel = fetchMyDataModels().first ?? createMyDataModel() else {
            return false
        }
        return myDataModel.wrappedFollowUids.contains(uid)
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

    // MARK: - データの追加

    // フォローUIDを追加する
    func addFollowUid(uid: String) {
        guard let myDataModel = fetchMyDataModels().first ?? createMyDataModel() else {
            print("MyDataModelの作成または取得に失敗しました")
            return
        }
        var uids = myDataModel.wrappedFollowUids
        uids.append(uid)
        myDataModel.followUids = uids as NSObject

        saveContext()
    }

    // コメントポストIDを追加する
    func addCommentPostId(postId: String) {
        guard let myDataModel = fetchMyDataModels().first ?? createMyDataModel() else {
            print("MyDataModelの作成または取得に失敗しました")
            return
        }
        var postIds = myDataModel.wrappedCommentPostIds
        postIds.append(postId)
        myDataModel.commentPostIds = postIds as NSObject

        saveContext()
    }

    // MARK: - データの削除

    // フォローUIDを削除する
    func removeFollowUid(uid: String) {
        guard let myDataModel = fetchMyDataModels().first ?? createMyDataModel() else {
            print("MyDataModelの作成または取得に失敗しました")
            return
        }
        var uids = myDataModel.wrappedFollowUids
        if let index = uids.firstIndex(of: uid) {
            uids.remove(at: index)
        }
        myDataModel.followUids = uids as NSObject

        saveContext()
    }

    // コメントポストIDを削除する
    func removeCommentPostId(postId: String) {
        guard let myDataModel = fetchMyDataModels().first ?? createMyDataModel() else {
            print("MyDataModelの作成または取得に失敗しました")
            return
        }
        var postIds = myDataModel.wrappedCommentPostIds
        if let index = postIds.firstIndex(of: postId) {
            postIds.remove(at: index)
        }
        myDataModel.commentPostIds = postIds as NSObject

        saveContext()
    }
}
