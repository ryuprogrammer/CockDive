import SwiftUI

struct MainColorEditViewModel {
    /// テーマカラーを保存
    func setMainColor(color: Color) {
        let userDefaultsColorModel = UserDefaultsColorModel()
        userDefaultsColorModel.saveColor(color: color)
    }
}
