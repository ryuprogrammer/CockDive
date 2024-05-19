import Foundation
import _PhotosUI_SwiftUI

class AddPostViewModel: ObservableObject {
    @Published var postData: [PostElement] = []
    let postDataModel = PostDataModel()
    let userFriendModel = UserFriendModel()
    
    // MARK: - データ追加
    /// Post追加/ 更新
    func addPost(post: PostElement) async {
        await postDataModel.addPost(post: post)
    }
    
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
    
    // MARK: - 写真処理
    /// 写真処理
    func castImageType(images: [PhotosPickerItem]) async -> UIImage? {
        var resultImage: UIImage?
        do {
            for photoPickerItem in images {
                if let data = try await photoPickerItem.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        resultImage = uiImage
                    }
                }
            }
        } catch {
            print(error)
        }
        return resultImage
    }
    
    /// UIImageをDataにキャスト
    func castUIImageToData(uiImage: UIImage?) -> Data? {
        guard let image = uiImage else { return nil }
        let data = image.jpegData(compressionQuality: 0.5)
        return data
    }
}
