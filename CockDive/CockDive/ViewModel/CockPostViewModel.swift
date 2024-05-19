import Foundation
import _PhotosUI_SwiftUI

class CockPostViewModel: ObservableObject {
    @Published var postData: [PostElement] = []
    let postDataModel = PostDataModel()
    let userFriendModel = UserFriendModel()
    
    // MARK: - データ追加
    /// Like
    func likePost(post: PostElement) async {
        await postDataModel.changeLikeToPost(post: post)
    }
    
    /// フォロー
    func followUser(friendUid: String) async {
        await userFriendModel.addUserFriend(friendUid: friendUid, friendType: .follow)
    }
    
    /// ブロック
    func blockUser(friendUid: String) async {
        await userFriendModel.addUserFriend(friendUid: friendUid, friendType: .block)
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
}
