import Foundation
import FirebaseAuth

class StartViewModel: ObservableObject {
    @Published var userStatus: UserStatus = .loading
    @Published var userUpdateStatus: UserUpdateStatus = .idle
    private var handle: AuthStateDidChangeListenerHandle!

    private let userDataModel = UserDataModel()
    private let userDefaultsDataModel = UserDefaultsDataModel()

    init() {
        // 認証状態の変化を監視するリスナー
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let _ = user {
                print("Sign-in")
                print("userStatus: \(self.userStatus)")
                if self.userDefaultsDataModel.userDataExists() {
                    self.userStatus = .normalUser
                    print("userStatus: \(self.userStatus)")
                } else {
                    self.userStatus = .nameRegistrationRequired
                    print("userStatus: \(self.userStatus)")
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

    /// Userの登録
    func addUser(nickName: String, iconImageData: Data?) {
        userUpdateStatus = .loading

        // Firebaseに追加
        userDataModel.addUser(user: UserElement(
            nickName: nickName,
            iconImage: iconImageData
        )) { result in
            switch result {
            case .success(let iconURL):
                // uidを取得して、UserDefaultsに追加
                if let uid = self.userDataModel.fetchUid() {
                    self.userDefaultsDataModel.addUserData(user: UserElement(
                        id: uid,
                        nickName: nickName,
                        iconImage: iconImageData,
                        iconURL: iconURL
                    ))
                    self.userUpdateStatus = .success(iconURL)
                } else {
                    self.userUpdateStatus = .error("Failed to fetch user UID.")
                }
            case .failure(let error):
                self.userUpdateStatus = .error(error.localizedDescription)
            }
        }
    }
}
