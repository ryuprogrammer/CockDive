import UIKit

extension UIImage {
    /// UIImageをDataにキャスト
    func castToData(compressionQuality: CGFloat = 0.1) -> Data? {
        for i in 0 ..< 10 {
            let q = CGFloat(CGFloat(i)/10)
            let size = NSData(data: self.jpegData(compressionQuality: q)!).count
            print("---------------------")
            print("クオリティー: \(q)")
            print("size: \(size)")
            if 1048576 < size {
                print("アウト")
            } else {
                print("OK")
            }
        }
        return self.jpegData(compressionQuality: compressionQuality)
    }
}
