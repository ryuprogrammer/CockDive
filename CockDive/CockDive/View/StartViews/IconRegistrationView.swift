import SwiftUI
import PhotosUI

struct IconRegistrationView: View {
    // 登録する写真
    @Binding var uiImage: UIImage?
    // 登録ボタンの処理
    let registrationAction: () -> Void
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
                Text("アイコンを選択してね！")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)

                // アルバムから選択
                PhotosPicker(
                    selection: $selectedImage,
                    maxSelectionCount: 1,
                    matching: .images,
                    preferredItemEncoding: .current,
                    photoLibrary: .shared()) {
                        ZStack {
                            if let uiImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: screenWidth / 3, height: screenWidth / 3)
                                    .clipShape(Circle())
                                    .padding(.bottom)
                            } else {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundStyle(Color.white)
                                    .frame(width: screenWidth / 3, height: screenWidth / 3)
                                    .clipShape(Circle())
                                    .padding(.bottom)
                            }

                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color.mainColor)
                                .padding(8)
                                .frame(width: screenWidth/8, height: screenWidth/8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: screenWidth / 10, y: screenWidth / 10)
                        }
                    }
                    .onChange(of: selectedImage) { newPhotoPickerItems in
                        Task {
                            guard let image = newPhotoPickerItems.first,
                                  let uiImage = await image.castImageType()
                            else { return }
                            DispatchQueue.main.async {
                                self.uiImage = uiImage
                                selectedImage.removeAll()
                            }
                        }
                    }

                HStack {
                    Text("テンプレートアイコン")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)

                    Spacer()
                }

                LazyVGrid(columns: Array(repeating: GridItem(), count: 4), spacing: 5) {
                    ForEach(0..<8, id: \.self) { index in
                        Image("iconSample\(index+1)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.mainColor)
                            .frame(width: screenWidth/5, height: screenWidth/5)
                            .clipShape(Circle())
                            .padding(2)
                            .onTapGesture {
                                if let image = UIImage(named: "iconSample\(index+1)") {
                                    uiImage = image
                                }
                            }
                    }
                }

                Spacer()

                // Sign-In状態なので登録画面に遷移
                if let uiImage {
                    LongBarButton(text: "ユーザー登録", isStroke: true) {
                        registrationAction()
                    }
                } else {
                    LongBarButton(text: "あとで追加", isStroke: true) {
                        registrationAction()
                    }
                }

                Spacer()
                    .frame(height: 100)
            }
            .padding()
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var uiImage: UIImage? = nil

        var body: some View {
            IconRegistrationView(uiImage: $uiImage) {
            }
        }
    }

    return PreviewWrapper()
}
