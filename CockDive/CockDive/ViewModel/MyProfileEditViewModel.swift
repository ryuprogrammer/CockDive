import Foundation
import Combine

class MyProfileEditViewModel: ObservableObject {
    private let userDataModel = UserDataModel()
    private let userDefaultsDataModel = UserDefaultsDataModel()

    @Published var status: UserUpdateStatus = .idle

    /// UserData取得
    func fetchUserData() -> UserElementForUserDefaults? {
        return userDefaultsDataModel.fetchUserData()
    }

    /// Userの登録
    func upDateUserData(
        nickName: String,
        introduction: String?,
        iconImage: Data?
    ) {
        status = .loading

        // Firebaseに追加
        userDataModel.addUser(user: UserElement(
            nickName: nickName,
            introduction: introduction,
            iconImage: iconImage
        )) { result in
            switch result {
            case .success(let iconURL):
                // uidを取得して、UserDefaultsに追加
                if let uid = self.userDataModel.fetchUid() {
                    self.userDefaultsDataModel.addUserData(user: UserElement(
                        id: uid,
                        nickName: nickName,
                        introduction: introduction,
                        iconImage: iconImage,
                        iconURL: iconURL
                    ))
                    self.status = .success(iconURL)
                } else {
                    self.status = .error("Failed to fetch user UID.")
                }
            case .failure(let error):
                self.status = .error(error.localizedDescription)
            }
        }
    }
}
