import Foundation
import FirebaseAuth

class StartViewModel: ObservableObject {
    // iOS16でも使うので、Publuish
    @Published var userStatus: UserStatus = .signInRequired
    private var handle: AuthStateDidChangeListenerHandle!
    
    private let userDataModel = UserDataModel()
    
    init() {
        // 認証状態の変化を監視するリスナー
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let _ = user {
                print("Sign-in")
                self.userStatus = .registrationRequired
            } else {
                print("Sign-out")
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
    
    /// Userの追加
    func addUser(nickName: String) async {
        await userDataModel.addUser(user: UserElement(nickName: nickName))
        DispatchQueue.main.async {
            // Publishで変更→UI処理なので、メインスレッドで処理する
            self.userStatus = .normalUser
        }
    }
}
