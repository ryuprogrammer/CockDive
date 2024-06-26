import CoreData

class MyPostCoreDataManager {
    static let shared = MyPostCoreDataManager()

    private init() {}

    var context: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }

    // MARK: - データの取得
    /// 指定された月のMyPostModelを取得する
    /// - Parameter date: 検索する月を含む日付
    /// - Returns: 指定された月に作成されたMyPostModelとその日のタプルの配列
    func fetchByMonth(date: Date) -> [(day: Int, posts: [MyPostModel])] {
        let request: NSFetchRequest<MyPostModel> = MyPostModel.fetchRequest()

        // Calendarを使って指定された月の開始日を取得
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            print("開始日を計算できませんでした")
            return []
        }

        // 指定された月の日数を取得
        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            print("月の日数を取得できませんでした")
            return []
        }

        // 月の最終日を計算
        guard let endOfMonth = calendar.date(byAdding: .day, value: range.count, to: startOfMonth) else {
            print("月の最終日を計算できませんでした")
            return []
        }

        // フェッチリクエストに使用する述語を作成
        let predicate = NSPredicate(format: "createAt >= %@ AND createAt < %@", startOfMonth as NSDate, endOfMonth as NSDate)
        request.predicate = predicate

        do {
            // データをフェッチ
            let results = try context.fetch(request)

            // フェッチした結果を日付ごとにグループ化して返す
            let groupedResults = Dictionary(grouping: results, by: { calendar.component(.day, from: $0.createAt ?? Date()) })
            return groupedResults.map { (day: $0.key, posts: $0.value) }.sorted { $0.day < $1.day }
        } catch {
            // エラーハンドリング
            print("指定された月のMyPostModelをフェッチできませんでした: \(error)")
            return []
        }
    }

    /// 全てのMyPostModelの数を取得する
    /// - Returns: MyPostModelの数
    func countAllPosts() -> Int {
        let request: NSFetchRequest<MyPostModel> = MyPostModel.fetchRequest()
        do {
            return try context.count(for: request)
        } catch {
            print("Failed to count MyPostModel: \(error)")
            return 0
        }
    }

    /// 指定されたIDのMyPostModelが存在するかどうかをチェックする
    /// - Parameter id: 存在をチェックするMyPostModelのID
    /// - Returns: 存在する場合はtrue、存在しない場合はfalse
    func checkIfExists(id: String) -> Bool {
        let request: NSFetchRequest<MyPostModel> = MyPostModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Failed to check if MyPostModel exists: \(error)")
            return false
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

    // MARK: - データの更新
    
    /// 指定されたIDのMyPostModelを更新する
    /// - Parameters:
    ///   - id: 更新するMyPostModelのID
    ///   - createAt: 新しい作成日時
    ///   - title: 新しいタイトル
    ///   - memo: 新しいメモ
    ///   - image: 新しい画像データ
    func update(
        id: String,
        createAt: Date,
        title: String,
        memo: String,
        image: Data
    ) {
        // MyPostModelのフェッチリクエストを作成
        let request: NSFetchRequest<MyPostModel> = MyPostModel.fetchRequest()
        // 指定されたIDに一致するレコードを検索する述語を設定
        request.predicate = NSPredicate(format: "id == %@", id)

        do {
            // 指定されたIDのレコードをフェッチ
            let results = try context.fetch(request)
            // フェッチした結果から最初のレコードを取得
            if let myPost = results.first {
                // レコードの各フィールドを新しい値で更新
                myPost.createAt = createAt
                myPost.title = title
                myPost.memo = memo
                myPost.image = image

                // コンテキストの変更を保存
                try context.save()
                print("Update successful for MyPostModel with id \(id)")
            } else {
                // 指定されたIDのレコードが見つからなかった場合のエラーメッセージ
                print("MyPostModel with id \(id) not found")
            }
        } catch {
            // エラーハンドリング: フェッチや保存に失敗した場合
            print("Failed to update MyPostModel: \(error)")
        }
    }


    // MARK: - データの削除

    /// 指定されたIDのMyPostModelを削除する
    /// - Parameter id: 削除するMyPostModelのID
    func delete(by id: String) {
        let request: NSFetchRequest<MyPostModel> = MyPostModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        do {
            let results = try context.fetch(request)
            if let myPost = results.first {
                context.delete(myPost)
                try context.save()
            } else {
                print("MyPostModel with id \(id) not found")
            }
        } catch {
            print("Failed to delete MyPostModel: \(error)")
        }
    }

    /// 全てのMyPostModelを削除する
    func deleteAllPosts() {
        let request: NSFetchRequest<MyPostModel> = MyPostModel.fetchRequest()
        do {
            let results = try context.fetch(request)
            for post in results {
                context.delete(post)
            }
            try context.save()
        } catch {
            print("Failed to delete all MyPostModel: \(error)")
        }
    }
}
