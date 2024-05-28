import SwiftUI
import PhotosUI

extension PhotosPickerItem {
    /// UIImageにキャスト
    func castImageType() async -> UIImage? {
        var resultImage: UIImage?
        do {
            if let data = try await self.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    resultImage = uiImage
                }
            }
        } catch {
            print(error)
        }
        return resultImage
    }
}
