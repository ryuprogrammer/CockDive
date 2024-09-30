import SwiftUI
import PhotosUI

struct MyProfileEditView: View {
    @ObservedObject var myProfileEditVM = MyProfileEditViewModel()
    @State private var nickName: String = ""
    @State private var introduction: String = ""
    @State private var uiImage: UIImage? = nil
    @State private var selectedImage: [PhotosPickerItem] = []
    @State private var nickNameErrorMessage = ""
    @State private var introductionErrorMessage = ""
    @State private var originalNickName: String = ""
    @State private var originalIntroduction: String = ""
    @State private var originalUIImage: UIImage? = nil
    @State private var showAlert = false
    @State private var isLoading: Bool = false

    @Environment(\.dismiss) private var dismiss

    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    var screenWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.width
        }
        return 400
    }
    @FocusState private var keybordFocuse: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                if myProfileEditVM.status == .loading {
                    ProgressView("保存中...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    PhotosPicker(
                        selection: $selectedImage,
                        maxSelectionCount: 1,
                        matching: .images,
                        preferredItemEncoding: .current,
                        photoLibrary: .shared()
                    ) {
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
                                    .foregroundStyle(Color.gray.opacity(0.5))
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

                    SectioinTitleView(text: "ニックネーム", isRequired: false)

                    TextField(text: $nickName) {
                        Text("ニックネーム")
                    }
                    .tint(Color.blackWhite)
                    .padding(8)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 0.6)
                    )
                    .onChange(of: nickName) { newValue in
                        validateNickName()
                    }

                    if !nickNameErrorMessage.isEmpty {
                        HStack {
                            Text(nickNameErrorMessage)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }

                    SectioinTitleView(text: "自己紹介文", isRequired: false)
                        .padding(.top)

                    TextEditor(text: $introduction)
                        .padding(5)
                        .tint(Color.blackWhite)
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
                        .onChange(of: introduction) { newValue in
                            validateIntroduction()
                        }
                        .onTapGesture {
                            keybordFocuse.toggle()
                        }

                    if !introductionErrorMessage.isEmpty {
                        HStack {
                            Text(introductionErrorMessage)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
            }
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolBarBackButtonView {
                        if myProfileEditVM.status != .loading {
                            if nickName != originalNickName || introduction != originalIntroduction || uiImage != originalUIImage {
                                showAlert = true
                            } else {
                                dismiss()
                            }
                        }
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
                        validateNickName()
                        validateIntroduction()
                        if nickNameErrorMessage.isEmpty && introductionErrorMessage.isEmpty &&
                            uiImage != nil &&
                            myProfileEditVM.status != .loading {

                            let imageData = uiImage?.castToData()
                            myProfileEditVM.upDateUserData(
                                nickName: nickName,
                                introduction: introduction,
                                iconImage: imageData
                            )
                        }
                    }
                }

                if self.keybordFocuse {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("完了") {
                            self.keybordFocuse = false
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(isLoading)
        .onAppear {
            FirebaseLog.shared.logScreenView(.myProfileEditView)
            if let userData = myProfileEditVM.fetchUserData() {
                nickName = userData.nickName
                originalNickName = userData.nickName
                introduction = userData.introduction ?? ""
                originalIntroduction = userData.introduction ?? ""
                guard let iconData = userData.iconImage else { return }
                uiImage = UIImage(data: iconData)
                originalUIImage = UIImage(data: iconData)
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
        .onChange(of: myProfileEditVM.status) { newStatus in
            if case .success(let iconURL) = newStatus {
                dismiss()
                print("Icon URL: \(iconURL)")
            } else if case .error(let error) = newStatus {
                print("エラー: \(error)")
            } else if case .loading = newStatus {
                isLoading = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("編集を保存しますか？"),
                primaryButton: .default(Text("保存")) {
                    validateNickName()
                    validateIntroduction()
                    if nickNameErrorMessage.isEmpty && introductionErrorMessage.isEmpty &&
                        uiImage != nil &&
                        myProfileEditVM.status != .loading {

                        let imageData = uiImage?.castToData()
                        myProfileEditVM.upDateUserData(
                            nickName: nickName,
                            introduction: introduction,
                            iconImage: imageData
                        )
                    }
                },
                secondaryButton: .cancel(Text("いいえ")) {
                    dismiss()
                }
            )
        }
    }

    private func validateNickName() {
        nickNameErrorMessage = ""
        if nickName.isEmpty {
            nickNameErrorMessage = "ニックネームを入力してください"
        } else if nickName.containsNGWord() {
            nickNameErrorMessage = "不適切な言葉が含まれています"
        } else if nickName.count < 2 || nickName.count > 8 {
            nickNameErrorMessage = "2文字以上8文字以下で入力してください。"
        }
    }

    private func validateIntroduction() {
        introductionErrorMessage = ""
        if introduction.containsNGWord() {
            introductionErrorMessage = "不適切な言葉が含まれています"
        } else if introduction.count > 150 {
            introductionErrorMessage = "自己紹介文は150文字以内で入力してください。"
        }
    }
}

#Preview {
    MyProfileEditView()
}
