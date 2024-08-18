import Foundation
import SwiftUI

extension Data {
    /// DataからUIImageを生成し、SwiftUIのImageに変換するメソッド
    func toImage() -> Image? {
        if let uiImage = UIImage(data: self) {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
}
