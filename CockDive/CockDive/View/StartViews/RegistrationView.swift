import SwiftUI

struct RegistrationView: View {
    // 登録するニックネーム
    @Binding var nickName: String
    // 登録ボタンの処理
    let registrationVoid: () -> Void
    
    var body: some View {
        ZStack {
            Color.mainColor
            VStack {
                Text("みんなのご飯")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                
                Spacer()
                
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
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Sign-In状態なので登録画面に遷移
                LongBarButton(text: "ユーザー登録", isStroke: true) {
                    registrationVoid()
                }
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    struct PreviewView: View {
        @State private var nickName: String = ""
        
        var body: some View {
            RegistrationView(nickName: $nickName) {
                // nothing to do
            }
        }
    }
    return PreviewView()
}
