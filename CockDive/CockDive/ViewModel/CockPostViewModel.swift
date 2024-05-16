import Foundation

class CockPostViewModel: ObservableObject {
    @Published var postData: [PostElement] = []
    let postDataModel = PostDataModel()
    
    // MARK: - データ追加
    /// Post追加/ 更新
    func addPost(post: PostElement) async {
        await postDataModel.addPost(post: post)
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
