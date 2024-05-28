import UIKit

extension UIImage {
    /// UIImageをDataにキャスト
    func castToData(compressionQuality: CGFloat = 0.5) -> Data? {
        return self.jpegData(compressionQuality: compressionQuality)
    }
}
