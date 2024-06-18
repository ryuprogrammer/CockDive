import SwiftUI

extension Color {
    /// メインカラー
    static var mainColor: Color {
        let userDefaultsColorModel = UserDefaultsColorModel()
        return userDefaultsColorModel.fetchColor()
    }
}
