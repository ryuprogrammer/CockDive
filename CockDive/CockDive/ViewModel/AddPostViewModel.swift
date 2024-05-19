import Foundation
import _PhotosUI_SwiftUI

class AddPostViewModel: ObservableObject {
    let postDataModel = PostDataModel()
    let userFriendModel = UserFriendModel()
    let userDataModel = UserDataModel()
    
    // MARK: - データ追加
    /// Post追加/ 更新
    func addPost(post: PostElement) async {
        var newPost = post
        let uid = fetchUid()
        
        if let userData = await userDataModel.fetchUserData(uid: uid) {
            newPost.postUserNickName = userData.nickName
            newPost.postUserIconImageURL = userData.iconURL
            await postDataModel.addPost(post: newPost)
        }
    }
    
    // MARK: - データ取得
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
