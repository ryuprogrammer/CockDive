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
    /// Post追加
    /// firebase（PostDataModelとUserPostDataModel）とCoreData
    func addPost(
        uid: String,
        date: Date,
        postImage: Data,
        title: String,
        memo: String
    ) {
        loadStatus = .loading

        let newPost = PostElement(
            uid: uid,
            postImage: postImage,
            title: title,
            memo: memo,
            isPrivate: false,
            createAt: date,
            likeCount: 0,
            likedUser: [],
            comment: []
        )

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
                        createAt: newPost.createAt,
                        title: newPost.title,
                        memo: newPost.memo ?? "",
                        image: newPost.postImage ?? Data()
                    )
                    self.loadStatus = .success
                case .failure(let error):
                    self.loadStatus = .error(error.localizedDescription)
                }
            }
        }
    }

    /// Postの更新
    /// firebase（PostDataModelとUserPostDataModel）とCoreData
    func upDate(
        editPost: PostElement,
        newDate: Date,
        newTitle: String,
        newMemo: String,
        newImage: Data?
    ) {
        loadStatus = .loading

        let newPost = PostElement(
            id: editPost.id,
            uid: editPost.uid,
            postImage: newImage,
            title: newTitle,
            memo: newMemo,
            isPrivate: editPost.isPrivate,
            createAt: newDate,
            likeCount: editPost.likeCount,
            likedUser: editPost.likedUser,
            comment: editPost.comment
        )

        postDataModel.addPost(post: newPost) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let postId):
                    Task {
                        // firebaseのuserPostDataModelに追加
                        await self.userPostDataModel.addPostId(postId: postId, userPostType: .post)
                    }
                    // CoreDataに保存
                    self.coreDataMyPostModel.update(
                        id: postId,
                        createAt: newPost.createAt,
                        title: newPost.title,
                        memo: newPost.memo ?? "",
                        image: newPost.postImage ?? Data()
                    )
                    self.loadStatus = .success
                case .failure(let error):
                    self.loadStatus = .error(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - データ取得
    /// uid取得
    func fetchUid() -> String {
        return postDataModel.fetchUid() ?? ""
    }
}
