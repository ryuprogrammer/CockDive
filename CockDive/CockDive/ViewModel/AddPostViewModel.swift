import Foundation
import _PhotosUI_SwiftUI

class AddPostViewModel: ObservableObject {
    let postDataModel = PostDataModel()
    let userFriendModel = UserFriendModel()
    let userDataModel = UserDataModel()
    let userPostDataModel = UserPostDataModel()
    let coreDataMyPostModel = MyPostCoreDataManager.shared

    // MARK: - データ追加
    /// Post追加/ 更新（firebaseとCoreData）
    func addPost(post: PostElement) async {
        var newPost = post
        let uid = fetchUid()
        
        // postIdを取得（nilなら新規追加なので作成）
        let postId = post.id ?? postDataModel.createNewDocId()
        // firebaseのPostDataModelに追加
        if let userData = await userDataModel.fetchUserData(uid: uid) {
            newPost.postUserNickName = userData.nickName
            newPost.postUserIconImage = userData.iconImage
            await postDataModel.addPost(post: newPost, newDocId: postId)
        }

        // firebaseのuserPostDataModelに追加
        await userPostDataModel.addPostId(postId: postId, userPostType: .post)

        // CoreDataに保存
        coreDataMyPostModel.create(
            id: postId,
            createAt: post.createAt,
            title: post.title,
            memo: post.memo ?? "",
            image: post.postImage ?? Data()
        )
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
