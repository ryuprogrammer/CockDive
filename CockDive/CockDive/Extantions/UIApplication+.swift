import Foundation
import SwiftUI

extension UIApplication {
    func keybordClose() {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
