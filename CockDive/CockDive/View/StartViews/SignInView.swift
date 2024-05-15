import SwiftUI

struct SignInView: View {
    @State private var isShowSheet = false
    
    var body: some View {
        ZStack {
            Color.mainColor
            VStack {
                Spacer()
                
                Text("みんなのご飯")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                // Sign-Out状態なのでSign-Inボタンを表示する
                LongBarButton(text: "サインイン", isStroke: true) {
                    self.isShowSheet.toggle()
                }
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .ignoresSafeArea(.all)
        .sheet(isPresented: $isShowSheet) {
            FirebaseAuthUIView()
        }
    }
}

#Preview {
    SignInView()
}
