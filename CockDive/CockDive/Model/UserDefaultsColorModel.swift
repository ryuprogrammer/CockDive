import SwiftUI

struct UserDefaultsColorModel {
    var colorKey: String = "colorKey"

    /// カラーを保存
    func saveColor(color: Color) {
        let uiColor = UIColor(color)
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(colorData, forKey: colorKey)
        }
    }

    /// カラーを取得
    func fetchColor() -> Color {
        guard let colorData = UserDefaults.standard.data(forKey: colorKey),
              let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) else {
            return .mainPink // デフォルトの色
        }
        return Color(uiColor)
    }
}
