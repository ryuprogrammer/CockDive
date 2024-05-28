import Foundation

class MyProfileEditViewModel: ObservableObject {
    private let userDataModel = UserDataModel()
    private let userDefaultsDataModel = UserDefaultsDataModel()

    /// UserData取得
    func fetchUserData() -> UserElementForUserDefaults? {
        return userDefaultsDataModel.fetchUserData()
    }

    /// Userの登録
    func upDateUserData(
        nickName: String,
        introduction: String?,
        iconImage: Data?
    ) async {
        // Firebaseに追加
        await userDataModel.addUser(user: UserElement(
            nickName: nickName,
            introduction: introduction,
            iconImage: iconImage
        ))
        // uidを取得して、UserDefaultsに追加
        if let uid = userDataModel.fetchUid() {
            userDefaultsDataModel.addUserData(user: UserElement(
                id: uid,
                nickName: nickName,
                introduction: introduction,
                iconImage: iconImage
            ))
        }
    }
}
