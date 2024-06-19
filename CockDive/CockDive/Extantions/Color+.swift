import SwiftUI

extension Color {
    /// メインカラー
    static var mainColor: Color {
        let userDefaultsColorModel = UserDefaultsColorModel()
        return userDefaultsColorModel.fetchColor()
    }

    /// ライトモードでmain、ダークモードでwhite
    static var mainWhite: Color {
        let userDefaultsColorModel = UserDefaultsColorModel()
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor(userDefaultsColorModel.fetchColor())
        })
    }
}
