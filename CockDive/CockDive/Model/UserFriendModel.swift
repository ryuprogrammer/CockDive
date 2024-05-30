import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserFriendModel {
    /// コレクション名
    private let userFriendCollection: String = "userFriendData"
    private let userCollection: String = "userData"

    private var db = Firestore.firestore()
    private let fetchLimit: Int = 20

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

    /// UIDを元にブロック解除
    func removeBlockForUser(uid: String) async {
        // uid取得
        guard let myUid = fetchUid() else { return }

        // 自分のUserFriendElementを取得
        if var myUserFriendElement = await fetchUserFriendData(uid: myUid) {
            // 自分のblockからuidを削除
            myUserFriendElement.block.removeAll(where: { $0 == uid })
            // 自分のUserFriendElementを更新
            await addUserFriendByUid(uid: myUid, userFriend: myUserFriendElement)
        }

        // 相手のUserFriendElementを取得
        if var friendUserFriendElement = await fetchUserFriendData(uid: uid) {
            // 相手のblockedByFriendからuidを削除
            friendUserFriendElement.blockedByFriend.removeAll(where: { $0 == myUid })
            // 相手のUserFriendElementを更新
            await addUserFriendByUid(uid: uid, userFriend: friendUserFriendElement)
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

    /// uidを指定してuserDataを取得: IconImage以外取得
    func fetchUserData(uid: String) async -> UserElement? {
        do {
            let document = try await db.collection(userCollection).document(uid).getDocument()

            guard document.data() != nil else {
                print("Document does not exist")
                return nil
            }

            let decodedUserData = try document.data(as: UserElement.self)

            // 使用するデータに応じて処理を追加
            print(decodedUserData)
            return decodedUserData
        } catch {
            print("Error fetching user data: \(error)")
        }
        return nil
    }

    /// friendTypeを指定して、uidを配列で取得
    func fetchFriendUidsByType(friendType: FriendType) async -> [String] {
        guard let myUid = fetchUid() else { return [] }

        do {
            let document = try await db.collection(userFriendCollection).document(myUid).getDocument()
            guard let data = document.data(), let myUserFriend = try? document.data(as: UserFriendElement.self) else {
                print("Error fetching or decoding data")
                return []
            }

            switch friendType {
            case .follow:
                return myUserFriend.follow
            case .block:
                return myUserFriend.block
            }
        } catch {
            print("Error fetchFriendUidsByType: \(error)")
        }
        return []
    }

    /// uidの配列を引数として、制限をしてUserDataを取得。出力は残りのuidの配列とUserDataの配列
    func fetchUserDataWithLimit(uids: [String]) async -> (remainingUids: [String], userData: [UserElement]) {
        let limitedUids = Array(uids.prefix(fetchLimit))
        var remainingUids = uids
        remainingUids.removeAll(where: { limitedUids.contains($0) })

        var userData: [UserElement] = []
        for uid in limitedUids {
            if let userFriendData = await fetchUserData(uid: uid) {
                userData.append(userFriendData)
            }
        }
        return (remainingUids, userData)
    }
}
