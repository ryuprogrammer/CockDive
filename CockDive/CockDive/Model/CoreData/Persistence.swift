import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        for _ in 0..<10 {
            let newMyData = MyDataModel(context: viewContext)
            newMyData.followUids = [] as NSObject
            newMyData.likePostIds = [] as NSObject
            newMyData.commentPostIds = [] as NSObject
        }

        for i in 0..<10 {
            let newMyPost = MyPostModel(context: viewContext)
            newMyPost.id = UUID().uuidString
            newMyPost.image = Data()
            newMyPost.title = "Sample Title \(i)"
            newMyPost.memo = "Sample Memo \(i)"
            newMyPost.createAt = Date()
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CockDive")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}