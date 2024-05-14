import SwiftUI

/// SingInまたはLogIn
struct SingInView: View {
    private var authenticationManager = AuthenticationManager()
    @State private var isShowSheet = false
    @State private var nickName: String = ""
    // キーボード制御
    @FocusState private var keybordFocuse: Bool
    
    var body: some View {
        ZStack {
            Color.mainColor
            VStack {
                Spacer()
                
                if authenticationManager.isSignIn {
                    
                    Text("みんなのご飯")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    // Sign-Out状態なのでSign-Inボタンを表示する
                    LongBarButton(text: "サインイン", isStroke: true) {
                        self.isShowSheet.toggle()
                    }
                } else {
                    Spacer()
                        .frame(height: 100)
                    
                    Text("ニックネームを登録")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                    
                    Text("8文字以内で入力してね")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                    
                    // 名前入力欄
                    TextField("ニックネームを入力", text: $nickName)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Sign-In状態なので登録画面に遷移
                    LongBarButton(text: "ユーザー登録", isStroke: true) {
                        
                    }
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
    SingInView()
}
