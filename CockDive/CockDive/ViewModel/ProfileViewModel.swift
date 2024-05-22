import Foundation

class ProfileViewModel: ObservableObject {
    

    // 投稿のid、いいねした投稿のidを取得
    let userPostDataModel = UserPostDataModel()
    // フォローとかフォロワーを取得
    let userFriendModel = UserFriendModel()
    let postDataModel = PostDataModel()

    // MARK: - データ取得
    /// UserFriendElement取得
    func fetchUserFriendData(uid: String) async {
        
    }
}
