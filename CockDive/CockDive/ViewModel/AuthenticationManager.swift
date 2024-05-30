import Foundation
import FirebaseAuth
import Combine

class AuthenticationManager: ObservableObject {
    // iOS16でも使うので、Publish
    @Published private(set) var isSignIn: Bool = false
    @Published private(set) var userStatus: UserStatus = .signInRequired
    private var handle: AuthStateDidChangeListenerHandle!

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
}
