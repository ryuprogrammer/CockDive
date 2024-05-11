import SwiftUI

struct LongBarButton: View {
    @State var text: String = "ボタン"
    
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    var body: some View {
        Button(action: {
            
        }, label: {
            Text(text)
                .frame(
                    width: window?.screen.bounds.width,
                    height: (window?.screen.bounds.height ?? 400) / 10
                )
                .padding()
                .background(Color.mainColor)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        })
    }
}

#Preview {
    LongBarButton()
}
