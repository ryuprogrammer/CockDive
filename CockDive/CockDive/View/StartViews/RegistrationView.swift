import SwiftUI
import PhotosUI

struct RegistrationView: View {
    // 登録するニックネーム
    @Binding var nickName: String
    // 登録する写真
    @State private var image: UIImage?
    // 登録ボタンの処理
    let registrationVoid: () -> Void
    // PhotosPickerで選択された写真
    @State private var selectedImage: [PhotosPickerItem] = []
    // MARK: - その他
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    var screenWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.width
        }
        return 400
    }

    var body: some View {
        ZStack {
            Color.mainColor
                .ignoresSafeArea(.all)
            VStack {
                Spacer()
                Text("ニックネームとアイコンを選択してね！")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)

                HStack {
                    // アルバムから選択
                    PhotosPicker(
                        selection: $selectedImage,
                        maxSelectionCount: 1,
                        matching: .images,
                        preferredItemEncoding: .current,
                        photoLibrary: .shared()) {
                            ZStack {
                                Image("cockImage")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: screenWidth / 4, height: screenWidth / 4)
                                    .clipShape(Circle())
                                    .padding(0)
                                    .padding(.bottom)

                                Image(systemName: "plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(Color.mainColor)
                                    .padding(8)
                                    .frame(width: screenWidth/11, height: screenWidth/11)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .offset(x: screenWidth / 12, y: screenWidth / 12)
                            }
                        }
                        .onChange(of: selectedImage) { newPhotoPickerItems in

                        }

                    // 名前入力欄
                    TextField("ニックネームを入力", text: $nickName)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal)

                Spacer()

                // Sign-In状態なので登録画面に遷移
                LongBarButton(text: "ユーザー登録", isStroke: true) {
                    registrationVoid()
                }

                Spacer()
                    .frame(height: 100)
            }
        }
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
