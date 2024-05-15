import Foundation
import FirebaseAuth

class StartViewModel: ObservableObject {
    // iOS16でも使うので、Publuish
    @Published var userStatus: UserStatus = .signInRequired
    private var handle: AuthStateDidChangeListenerHandle!
    
    private let userDataModel = UserDataModel()
    private let userDefaultsDataModel = UserDefaultsDataModel()
    
    init() {
        // 認証状態の変化を監視するリスナー
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let _ = user {
                print("Sign-in")
                if userDefaultsDataModel.userDataExists() {
                    userStatus = .normalUser
                } else {
                    userStatus = .registrationRequired
                }
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
    
    /// Userの追加
    func addUser(nickName: String) async {
        await userDataModel.addUser(user: UserElement(nickName: nickName))
        if let uid = userDataModel.fetchUid() {
            userDefaultsDataModel.addUserData(user: UserElement(
                id: uid,
                nickName: nickName
            ))
        }
        
        DispatchQueue.main.async {
            // Publishで変更→UI処理なので、メインスレッドで処理する
            self.userStatus = .normalUser
        }
    }
}
