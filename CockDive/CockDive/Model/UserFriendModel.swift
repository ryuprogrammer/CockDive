import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserFriendModel {
    /// コレクション名
    private let userFriendCollection: String = "userFriendData"

    private var db = Firestore.firestore()

    // MARK: - データ追加
    /// UserFriendDataを編集
    func addUserFriend(friendUid: String, friendType: FriendType) async {
        // uid取得
        guard let myUid = fetchUid() else { return }
        // 自分のUserFriendElement: 初期値
        var myNewUserFriendElement = UserFriendElement(
            id: myUid,
            followCount: 0,
            follow: [],
            followerCount: 0,
            follower: [],
            block: [],
            blockedByFriend: []
        )

        // UserFriendElement取得: 自分
        if let myUserFriend = await fetchUserFriendData(uid: myUid) {
            myNewUserFriendElement = myUserFriend
            if friendType == .follow {
                // フォローしているか
                if myNewUserFriendElement.follow.contains(friendUid) {
                    myNewUserFriendElement.followCount = myUserFriend.followCount - 1
                    myNewUserFriendElement.follow.removeAll(where: {$0 == friendUid})
                } else {
                    myNewUserFriendElement.followCount = myUserFriend.followCount + 1
                    myNewUserFriendElement.follow.append(friendUid)
                }
            } else if friendType == .block {
                // ブロックしているか
                if myNewUserFriendElement.block.contains(friendUid) {
                    myNewUserFriendElement.block.removeAll(where: {$0 == friendUid})
                } else {
                    myNewUserFriendElement.block.append(friendUid)
                }
            }
        } else { // 元々データがない場合は新規追加
            if friendType == .follow {
                myNewUserFriendElement.followCount = 1
                myNewUserFriendElement.follow.append(friendUid)
            } else if friendType == .block {
                myNewUserFriendElement.block.append(friendUid)
            }
        }

        // 自分のUserFriendElementを追加/ 更新
        await addUserFriendByUid(uid: myUid, userFriend: myNewUserFriendElement)

        // 相手のUserFriendElement: 初期値
        var friendNewUserFriendElement = UserFriendElement(
            id: friendUid,
            followCount: 0,
            follow: [],
            followerCount: 0,
            follower: [],
            block: [],
            blockedByFriend: []
        )

        // UserFriendElement取得: 相手
        if let friendUserFriend = await fetchUserFriendData(uid: friendUid) {
            friendNewUserFriendElement = friendUserFriend
            if friendType == .follow {
                // 相手視点で、自分にフォローされてるか
                if friendNewUserFriendElement.follower.contains(myUid) {
                    friendNewUserFriendElement.followerCount = friendUserFriend.followerCount - 1
                    friendNewUserFriendElement.follower.removeAll(where: {$0 == myUid})
                } else {
                    friendNewUserFriendElement.followerCount = friendUserFriend.followerCount + 1
                    friendNewUserFriendElement.follower.append(myUid)
                }
            } else if friendType == .block {
                // ブロックしているか
                if friendNewUserFriendElement.blockedByFriend.contains(myUid) {
                    friendNewUserFriendElement.blockedByFriend.removeAll(where: {$0 == myUid})
                } else {
                    friendNewUserFriendElement.blockedByFriend.append(myUid)
                }
            }
        } else { // 元々データがない場合は新規追加
            if friendType == .follow {
                friendNewUserFriendElement.followerCount = 1
                friendNewUserFriendElement.follower.append(myUid)
            } else if friendType == .block {
                friendNewUserFriendElement.blockedByFriend.append(myUid)
            }
        }

        // 相手のUserFriendElementを追加/ 更新
        await addUserFriendByUid(uid: friendUid, userFriend: friendNewUserFriendElement)
    }

    /// Uidを元にUserFriend追加/ 更新
    func addUserFriendByUid(uid: String, userFriend: UserFriendElement) async {
        do {
            // 指定したUIDを持つドキュメントデータに追加（または更新）
            try db.collection(userFriendCollection).document(uid).setData(from: userFriend)
        } catch {
            print("Error adding/updating userFriend: \(error)")
        }
    }

    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String? {
        return Auth.auth().currentUser?.uid
    }

    /// uidを指定してuserFriendDataを取得
    func fetchUserFriendData(uid: String) async -> UserFriendElement? {
        if uid.isEmpty {
            return nil
        }

        do {

            let document = try await db.collection(userFriendCollection).document(uid).getDocument()

            guard document.data() != nil else {
                print("Document does not exist: fetchUserFriendData")
                return nil
            }

            let decodedUserFriendData = try document.data(as: UserFriendElement.self)
            return decodedUserFriendData
        } catch {
            print("Error fetchUserFriendData: \(error)")
        }
        return nil
    }
}
