import Foundation

class SettingViewModel: ObservableObject {
    /// ユーザーデータ
    @Published var userData: UserElementForUserDefaults? = nil

    private let userDefaultsDataModel = UserDefaultsDataModel()

    /// UserData取得
    func fetchUserData() {
        userData = userDefaultsDataModel.fetchUserData()
    }
}
