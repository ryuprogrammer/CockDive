import Foundation
import CoreData

@objc(MyDataModel)
public class MyDataModel: NSManagedObject {
    // MARK: - データの取得

    /// followUids配列を取得する
    func getFollowUids() -> [String] {
        return wrappedFollowUids
    }

    /// likePostIds配列を取得する
    func getLikePostIds() -> [String] {
        return wrappedLikePostIds
    }

    /// commentPostIds配列を取得する
    func getCommentPostIds() -> [String] {
        return wrappedCommentPostIds
    }

    // MARK: - データの追加

    /// followUidsに文字列を追加する
    func addFollowUid(_ uid: String, context: NSManagedObjectContext) {
        var uids = wrappedFollowUids
        uids.append(uid)
        followUids = uids as NSObject

        do {
            try context.save()
        } catch {
            print("Failed to add followUid: \(error)")
        }
    }

    /// likePostIdsに文字列を追加する
    func addLikePostId(_ postId: String, context: NSManagedObjectContext) {
        var postIds = wrappedLikePostIds
        postIds.append(postId)
        likePostIds = postIds as NSObject

        do {
            try context.save()
        } catch {
            print("Failed to add likePostId: \(error)")
        }
    }

    /// commentPostIdsに文字列を追加する
    func addCommentPostId(_ postId: String, context: NSManagedObjectContext) {
        var postIds = wrappedCommentPostIds
        postIds.append(postId)
        commentPostIds = postIds as NSObject

        do {
            try context.save()
        } catch {
            print("Failed to add commentPostId: \(error)")
        }
    }

    // MARK: - データの削除

    /// followUidsから指定された文字列を削除する
    func removeFollowUid(_ uid: String, context: NSManagedObjectContext) {
        var uids = wrappedFollowUids
        if let index = uids.firstIndex(of: uid) {
            uids.remove(at: index)
        }
        followUids = uids as NSObject

        do {
            try context.save()
        } catch {
            print("Failed to remove followUid: \(error)")
        }
    }

    /// likePostIdsから指定された文字列を削除する
    func removeLikePostId(_ postId: String, context: NSManagedObjectContext) {
        var postIds = wrappedLikePostIds
        if let index = postIds.firstIndex(of: postId) {
            postIds.remove(at: index)
        }
        likePostIds = postIds as NSObject

        do {
            try context.save()
        } catch {
            print("Failed to remove likePostId: \(error)")
        }
    }

    /// commentPostIdsから指定された文字列を削除する
    func removeCommentPostId(_ postId: String, context: NSManagedObjectContext) {
        var postIds = wrappedCommentPostIds
        if let index = postIds.firstIndex(of: postId) {
            postIds.remove(at: index)
        }
        commentPostIds = postIds as NSObject

        do {
            try context.save()
        } catch {
            print("Failed to remove commentPostId: \(error)")
        }
    }
}
