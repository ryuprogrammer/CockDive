import SwiftUI
import PhotosUI

struct MyProfileEditView: View {
    @ObservedObject var myProfileEditVM = MyProfileEditViewModel()
    @State private var nickName: String = ""
    @State private var introduction: String = ""
    @State private var uiImage: UIImage? = UIImage()
    // PhotosPickerで選択された写真
    @State private var selectedImage: [PhotosPickerItem] = []

    // モーダル制御
    @Environment(\.dismiss) private var dismiss

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
    // キーボード制御
    @FocusState private var keybordFocuse: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
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
                                    .frame(width: screenWidth / 3, height: screenWidth / 3)
                                    .clipShape(Circle())
                                    .padding(.bottom)
                            }

                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color.white)
                                .padding(8)
                                .frame(width: screenWidth/9, height: screenWidth/9)
                                .background(Color.mainColor)
                                .clipShape(Circle())
                                .offset(x: screenWidth / 9, y: screenWidth / 9)
                        }
                    }
                    .onChange(of: selectedImage) { newPhotoPickerItems in
                        Task {
                            guard let imageData = newPhotoPickerItems.first,
                                  let uiImage = await imageData.castImageType() else {
                                      return
                                  }
                            self.uiImage = uiImage
                            selectedImage.removeAll()
                        }
                    }

                SectioinTitleView(text: "名前", isRequired: false)

                TextField(text: $nickName) {
                    Text("ニックネーム")
                }
                .padding(8)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 0.6)
                )
                .padding(.bottom)

                SectioinTitleView(text: "自己紹介文", isRequired: false)

                TextEditor(text: $introduction)
                    .padding(5)
                    .focused($keybordFocuse)
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 0.6)
                    )
                    .overlay(alignment: .topLeading) {
                        Text(introduction == "" ? "毎日自炊してます！" : "")
                            .foregroundStyle(Color.gray.opacity(0.5))
                            .padding(12)
                    }
                    .onTapGesture {
                        keybordFocuse.toggle()
                    }

                Spacer()
            }
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolBarBackButtonView {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("プロフィールを編集")
                        .foregroundStyle(Color.white)
                        .font(.title3)
                        .fontWeight(.bold)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    ToolBarAddButtonView(text: "保存") {
                        Task {
                            let imageData = uiImage?.castToData()
                            await myProfileEditVM.upDateUserData(
                                nickName: nickName,
                                introduction: introduction,
                                iconImage: imageData
                            )
                            dismiss()
                        }
                    }
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完了") {
                        self.keybordFocuse = false
                    }
                }
            }
        }
        .onAppear {
            if let userData = myProfileEditVM.fetchUserData() {
                nickName = userData.nickName
                introduction = userData.introduction ?? ""
                guard let iconData = userData.iconImage else { return }
                uiImage = UIImage(data: iconData)
            }
        }
    }
}

#Preview {
    MyProfileEditView()
}
