import SwiftUI

struct StartView: View {
    var body: some View {
        ZStack {
            Color.mainColor
            
            VStack {
                Text("みんなのご飯")
                
                LongBarButton(text: "初めての方はこちら") {
                    
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    StartView()
}
