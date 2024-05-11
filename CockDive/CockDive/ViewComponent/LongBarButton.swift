import SwiftUI

struct LongBarButton: View {
    @State var text: String = "ボタン"
    
//    let deviceWidth = UIScreen
    var body: some View {
        Button(action: {
            
        }, label: {
            Text(text)
                .frame(width: 100)
        })
    }
}

#Preview {
    LongBarButton()
}
