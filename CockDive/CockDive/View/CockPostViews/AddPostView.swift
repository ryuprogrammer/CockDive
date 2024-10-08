import SwiftUI
import PhotosUI

enum PostType: String {
    /// 新規投稿
    case add = "新規投稿"
    /// 編集
    case edit = "投稿を編集"

    var buttonText: String {
        switch self {
        case .add:
            return "投稿"
        case .edit:
            return "更新"
        }
    }
}

struct AddPostView: View {
    let postType: PostType
    /// 編集の場合のみ受け取る
    let editPost: PostElement?
    @StateObject private var addPostVM = AddPostViewModel()
    @State private var newDate: Date = Date()
    @State private var newTitle: String = ""
    @State private var newMemo: String = ""
    @State private var newImage: UIImage?
    @State private var newIsPrivate: Bool = false
    @State private var titleErrorMessage = ""
    @State private var memoErrorMessage = ""
    @State private var imageErrorMessage = ""
    @State private var showErrorDialog = false
    @State private var showAlertDialog = false
    @State private var isPresentedCameraView: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @FocusState private var keybordFocuse: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = false

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
        NavigationStack {
            ScrollView {
                VStack(alignment: .center) {
                    DatePicker(selection: $newDate, in: ...Date(), displayedComponents: .date) {
                        SectioinTitleView(text: "いつ食べた？", isRequired: false)
                    }
                    .padding(.top)
                    
                    SectioinTitleView(text: "まずは写真を追加しよう！", isRequired: true)
                        .padding(.top)

                    if let newImage {
                        Image(uiImage: newImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth*3/5, height: screenWidth*3/5)
                            .clipShape(Rectangle())

                        HStack {
                            Spacer()
                            Button {
                                self.newImage = nil
                            } label: {
                                StrokeIconButtonUI(text: "写真を選び直す", icon: "gobackward", size: .small)
                            }
                        }
                    } else {
                        Button {
                            FirebaseLog.shared.logButtonTap(.albumButton)
                            imagePickerSourceType = .photoLibrary
                            showImagePicker = true
                        } label: {
                            StrokeIconButtonUI(text: "アルバムから選ぶ", icon: "photo.on.rectangle.angled", size: .large)
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker() { selectedImage in
                                if let selectedImage = selectedImage {
                                    newImage = selectedImage
                                }
                            }
                            .ignoresSafeArea(.all)
                        }

                        Button {
                            FirebaseLog.shared.logButtonTap(.photoButton)
                            imagePickerSourceType = .camera
                            isPresentedCameraView = true
                        } label: {
                            StrokeIconButtonUI(text: "写真を撮る", icon: "camera", size: .large)
                        }
                        .fullScreenCover(isPresented: $isPresentedCameraView) {
                            CameraView(image: $newImage)
                                .ignoresSafeArea()
                        }
                    }

                    if !imageErrorMessage.isEmpty {
                        Text(imageErrorMessage)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.red)
                    }

                    SectioinTitleView(text: "料理名を入力", isRequired: true)
                        .padding(.top)

                    TextField("料理名を入力", text: $newTitle)
                        .padding(7)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 0.6)
                        )
                        .tint(Color.blackWhite)
                        .onChange(of: newTitle) { _ in
                            validateTitle()
                        }
                        .onTapGesture {
                            FirebaseLog.shared.logButtonTap(.titleButton)
                        }

                    if !titleErrorMessage.isEmpty {
                        Text(titleErrorMessage)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.red)
                    }

                    SectioinTitleView(text: "ご飯のメモをしよう", isRequired: false)
                        .padding(.top)

                    TextEditor(text: $newMemo)
                        .focused($keybordFocuse)
                        .padding(6)
                        .tint(Color.blackWhite)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 0.6)
                        )
                        .overlay(alignment: .topLeading) {
                            Text(newMemo.isEmpty ? "ご飯のメモ\n 例） 食べすぎた。。。" : "")
                                .foregroundStyle(Color.gray.opacity(0.5))
                                .padding(7)
                                .padding(.vertical, 3)
                        }
                        .onChange(of: newMemo) { _ in
                            validateMemo()
                        }
                        .onTapGesture {
                            FirebaseLog.shared.logButtonTap(.memoButton)
                            keybordFocuse.toggle()
                        }

                    if !memoErrorMessage.isEmpty {
                        Text(memoErrorMessage)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.red)
                    }

                    Spacer()
                        .frame(height: 10)
                        .listRowSeparator(.hidden)

                    Spacer()
                }
            }
            .padding(.horizontal)
            .overlay {
                if addPostVM.loadStatus == .loading {
                    ProgressView("投稿中...")
                        .font(.title)
                        .foregroundStyle(Color.white)
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.5))
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolBarBackButtonView {
                        if addPostVM.loadStatus != .loading {
                            if newImage != nil || !newTitle.isEmpty || !newMemo.isEmpty {
                                showAlertDialog = true
                            } else {
                                dismiss()
                            }
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(postType.rawValue)
                        .foregroundStyle(Color.white)
                        .font(.title3)
                        .fontWeight(.bold)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    ToolBarAddButtonView(text: postType.buttonText) {
                        keybordFocuse = false
                        validateTitle()
                        validateMemo()
                        validateImage()
                        if titleErrorMessage.isEmpty &&
                            memoErrorMessage.isEmpty &&
                            newImage != nil &&
                            addPostVM.loadStatus != .loading {
                            Task {
                                guard let dataImage = newImage?.castToData() else { return }
                                if postType == .add {
                                    FirebaseLog.shared.logButtonTap(.addPostButton)
                                    // firebase（PostDataModelとUserPostDataModel）とCoreDataに保存
                                    addPostVM.addPost(
                                        uid: addPostVM.fetchUid(),
                                        date: newDate,
                                        postImage: dataImage,
                                        title: newTitle,
                                        memo: newMemo
                                    )
                                } else if postType == .edit {
                                    guard let editPost else { return }
                                    FirebaseLog.shared.logButtonTap(.editPostButton)
                                    // firebase（PostDataModelとUserPostDataModel）とCoreDataに更新
                                    addPostVM.upDate(
                                        editPost: editPost,
                                        newDate: newDate,
                                        newTitle: newTitle,
                                        newMemo: newMemo,
                                        newImage: dataImage
                                    )
                                }
                            }
                        }
                    }
                }

                if keybordFocuse {
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
        .alert(isPresented: $showErrorDialog) {
            Alert(
                title: Text("エラー"),
                message: Text(addPostVM.loadStatus?.errorDescription ?? "不明なエラーが発生しました"),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showAlertDialog) {
            Alert(
                title: Text("投稿が消えてしまいます！"),
                primaryButton: .cancel(Text("キャンセル")),
                secondaryButton: .destructive(Text("OK")) {
                    dismiss()
                }
            )
        }
        .onChange(of: addPostVM.loadStatus) { newStatus in
            if case .error(_) = addPostVM.loadStatus {
                showErrorDialog = true
            } else if case .success = addPostVM.loadStatus {
                dismiss()
            } else if case .loading = addPostVM.loadStatus {
                isLoading = true
            }
        }
        .onAppear {
            FirebaseLog.shared.logScreenView(.addPostView)
            // 編集の場合は初期値挿入
            if let editPost {
                let date = editPost.createAt
                let title = editPost.title
                let memo = editPost.memo
                guard let imageData = editPost.postImage else { return }
                self.newDate = date
                self.newTitle = title
                self.newMemo = memo ?? ""
                self.newImage = UIImage(data: imageData)
            }
        }
    }

    private func validateTitle() {
        titleErrorMessage = ""
        if newTitle.isEmpty {
            titleErrorMessage = "料理名を入力してください"
        } else if newTitle.containsNGWord() {
            titleErrorMessage = "不適切な言葉が含まれています"
        } else if newTitle.count > 15 {
            titleErrorMessage = "料理名は15文字以下で入力してください"
        }
    }

    private func validateMemo() {
        memoErrorMessage = ""
        if newMemo.containsNGWord() {
            memoErrorMessage = "不適切な言葉が含まれています"
        } else if newMemo.count > 150 {
            memoErrorMessage = "メモは150文字以下で入力してください"
        }
    }

    private func validateImage() {
        imageErrorMessage = ""
        if newImage == nil {
            imageErrorMessage = "写真を追加してください"
        }
    }
}

extension PostStatus {
    var errorDescription: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var onImagePicked: (UIImage?) -> Void

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.onImagePicked(uiImage)
            } else {
                parent.onImagePicked(nil)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImagePicked(nil)
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    AddPostView(postType: .add, editPost: nil)
}
