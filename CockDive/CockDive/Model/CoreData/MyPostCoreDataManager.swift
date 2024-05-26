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
    func fetchByMonth(date: Date) -> [(day: Int, post: MyPostModel)] {
        let request: NSFetchRequest<MyPostModel> = MyPostModel.fetchRequest()

        // Calendarを使って指定された月の開始日を取得
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!

        // 指定された月の日数を取得
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!

        // 月の最終日を計算
        let endOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth)!

        // フェッチリクエストに使用する述語を作成
        let predicate = NSPredicate(format: "createAt >= %@ AND createAt < %@", startOfMonth as NSDate, endOfMonth as NSDate)
        request.predicate = predicate

        do {
            // データをフェッチ
            let results = try context.fetch(request)

            // フェッチした結果をタプルの配列に変換し、返す
            return results.map { (day: calendar.component(.day, from: $0.createAt ?? Date()), post: $0) }
        } catch {
            // エラーハンドリング
            print("Failed to fetch MyPostModel for the month: \(error)")
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
