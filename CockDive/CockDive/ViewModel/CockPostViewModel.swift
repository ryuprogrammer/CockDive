import Foundation
import _PhotosUI_SwiftUI

class CockPostViewModel: ObservableObject {
    @Published var postData: [PostElement] = []
    let userDataModel = UserDataModel()
    let postDataModel = PostDataModel()
    let userFriendDataModel = UserFriendModel()
    let userPostDataModel = UserPostDataModel()
    
    // MARK: - データ追加
    /// Like
    func likePost(post: PostElement) async {
        await postDataModel.changeLikeToPost(post: post)
    }
    
    /// フォロー
    func followUser(friendUid: String) async {
        await userFriendDataModel.addUserFriend(friendUid: friendUid, friendType: .follow)
    }
    
    /// ブロック
    func blockUser(friendUid: String) async {
        await userFriendDataModel.addUserFriend(friendUid: friendUid, friendType: .block)
    }
    
    /// 通報
    func reportUser(friendUid: String) {
        // TODO: 通報処理書く
    }
    
    // MARK: - データ取得
    /// Postを取得
    func fetchPost() async {
        let data = await postDataModel.fetchPostData()
        DispatchQueue.main.async {
            print("data: \(data)")
            self.postData = data
        }
    }
    
    /// uid取得
    func fetchUid() -> String {
        return postDataModel.fetchUid() ?? ""
    }
    
    /// userDate取得
    func fetchUserData() async -> UserElement? {
        let uid = fetchUid()
        return await userDataModel.fetchUserData(uid: uid)
    }
    
    /// UserFriendElement取得
    func fetchUserFriendElement() async -> UserFriendElement? {
        let uid = fetchUid()
        return await userFriendDataModel.fetchUserFriendData(uid: uid)
    }
    
    /// UserPostElement取得
    func fetchUserPostElement() async -> UserPostElement? {
        let uid = fetchUid()
        return await userPostDataModel.fetchUserPostData(uid: uid)
    }
    
    // MARK: - その他
    /// フォローしているか判定
    func checkIsFollow(userFriendData: UserFriendElement?, friendUid: String) -> Bool {
        guard let userFriendData else { return false }
        
        if userFriendData.follow.contains(friendUid) {
            return true
        } else {
            return false
        }
    }
    
    /// ライクしているか判定
    func checkIsLike(userPostData: UserPostElement?, postId: String) -> Bool {
        guard let userPostData else { return false }
        if userPostData.likePost.contains(postId) {
            return true
        } else {
            return false
        }
    }
}
