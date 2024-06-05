import Foundation
import FirebaseAuth
import Combine

class AuthenticationManager: ObservableObject {
    // iOS16でも使うので、Publish
    @Published private(set) var isSignIn: Bool = false
    @Published private(set) var userStatus: UserStatus = .signInRequired
    private var handle: AuthStateDidChangeListenerHandle!

    let userDataModel = UserDataModel()
    let postDataModel = PostDataModel()
    let userDefaultsModel = UserDefaultsDataModel()
    let myPostCoreDataManager = MyPostCoreDataManager.shared
    let likePostCoreDataManager = LikePostCoreDataManager.shared
    let myDataCoreDataManager = MyDataCoreDataManager.shared

    init() {
        // 認証状態の変化を監視するリスナー
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let _ = user {
                print("Sign-in")
                self.isSignIn = true
                self.userStatus = .nameRegistrationRequired
            } else {
                print("Sign-out")
                self.isSignIn = false
                self.userStatus = .signInRequired
            }
        }
    }

    deinit {
        // 認証状態の変化の監視を解除する
        Auth.auth().removeStateDidChangeListener(handle)
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
        self.userStatus = .signInRequired
    }

    /// 登録終わって、Statusを通常ユーザーに変更
    func register() {
        self.userStatus = .normalUser
    }

    /// アカウントを削除するメソッド
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is signed in."])))
            return
        }

        user.delete { error in
            if let error = error {
                print("Error deleting account: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Account deleted successfully")
                self.isSignIn = false
                self.userStatus = .signInRequired
                completion(.success(()))
            }
        }
    }

    /// データを全て削除
    func deleteAllData(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            deleteAllUserData()
            deleteAllPosts()
            deleteAllLikedPosts()
            deleteAllMyDataModels()
            await deleteUser(completion: completion)
        }
    }

    // MARK: - userDefaultsModel

    private func deleteAllUserData() {
        userDefaultsModel.removeAllUserData()
    }

    // MARK: - CoreData

    private func deleteAllPosts() {
        myPostCoreDataManager.deleteAllPosts()
    }

    private func deleteAllLikedPosts() {
        likePostCoreDataManager.deleteAllLikedPosts()
    }

    private func deleteAllMyDataModels() {
        myDataCoreDataManager.deleteAllMyDataModels()
    }

    // MARK: - Firebase

    private func deleteUser(completion: @escaping (Result<Void, Error>) -> Void) async {
        await userDataModel.deleteAllUserData(completion: completion)
    }
}
