import Foundation
import PhotosUI

enum PostStatus: Equatable {
    case loading
    case success
    case error(String)
}

class AddPostViewModel: ObservableObject {
    let postDataModel = PostDataModel()
    let userFriendModel = UserFriendModel()
    let userDataModel = UserDataModel()
    let userPostDataModel = UserPostDataModel()
    let coreDataMyPostModel = MyPostCoreDataManager.shared
    let userDefaultsDataModel = UserDefaultsDataModel()

    @Published var loadStatus: PostStatus?

    // MARK: - データ追加
    /// Post追加/ 更新（firebaseとCoreData）
    func addPost(post: PostElement) {
        loadStatus = .loading

        var newPost = post

        if let userData = userDefaultsDataModel.fetchUserData() {
            newPost.postUserNickName = userData.nickName
            newPost.postUserIconImageURL = userData.iconURL
            print("データ追加かいし")
            postDataModel.addPost(post: newPost) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let postId):
                        Task {
                            // firebaseのuserPostDataModelに追加
                            await self.userPostDataModel.addPostId(postId: postId, userPostType: .post)
                        }
                        // CoreDataに保存
                        self.coreDataMyPostModel.create(
                            id: postId,
                            createAt: post.createAt,
                            title: post.title,
                            memo: post.memo ?? "",
                            image: post.postImage ?? Data()
                        )
                        self.loadStatus = .success
                        print("成功")
                    case .failure(let error):
                        print("エラーーーー: \(error.localizedDescription)")
                        self.loadStatus = .error(error.localizedDescription)
                    }
                }
            }
        } else {
            loadStatus = .error("User data not found")
        }
    }

    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String {
        return postDataModel.fetchUid() ?? ""
    }
}
