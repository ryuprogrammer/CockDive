import SwiftUI
import PhotosUI

struct AddPostView: View {
    @StateObject private var addPostVM = AddPostViewModel()
    @State private var title: String = ""
    @State private var memo: String = ""
    @State private var isPrivate: Bool = false
    @State private var titleErrorMessage = ""
    @State private var memoErrorMessage = ""
    @State private var imageErrorMessage = ""
    @State private var showErrorDialog = false
    @State private var showAlertDialog = false
    @State private var isPresentedCameraView: Bool = false
    @State private var image: UIImage?
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
            ScrollViewReader { reader in
                ScrollView {
                    SectioinTitleView(text: "まずは写真を追加しよう！", isRequired: true)
                        .padding(.top)

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth*3/5, height: screenWidth*3/5)
                            .clipShape(Rectangle())

                        HStack {
                            Spacer()
                            Button {
                                self.image = nil
                            } label: {
                                StrokeIconButtonUI(text: "写真を選び直す", icon: "gobackward", size: .small)
                            }
                        }
                    } else {
                        Button {
                            imagePickerSourceType = .photoLibrary
                            showImagePicker = true
                        } label: {
                            StrokeIconButtonUI(text: "アルバムから選ぶ", icon: "photo.on.rectangle.angled", size: .large)
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker() { selectedImage in
                                if let selectedImage = selectedImage {
                                    image = selectedImage
                                }
                            }
                            .ignoresSafeArea(.all)
                        }

                        Button {
                            imagePickerSourceType = .camera
                            isPresentedCameraView = true
                        } label: {
                            StrokeIconButtonUI(text: "写真を撮る", icon: "camera", size: .large)
                        }
                        .fullScreenCover(isPresented: $isPresentedCameraView) {
                            CameraView(image: $image)
                                .ignoresSafeArea()
                        }
                    }

                    if !imageErrorMessage.isEmpty {
                        Text(imageErrorMessage)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.red)
                    }

                    SectioinTitleView(text: "料理名を入力", isRequired: true)

                    TextField("料理名を入力", text: $title)
                        .padding(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.6)
                        )
                        .onChange(of: title) { _ in
                            validateTitle()
                        }

                    if !titleErrorMessage.isEmpty {
                        Text(titleErrorMessage)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.red)
                    }

                    SectioinTitleView(text: "ご飯のメモをしよう", isRequired: false)

                    TextEditor(text: $memo)
                        .focused($keybordFocuse)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.6)
                        )
                        .overlay(alignment: .topLeading) {
                            Text(memo.isEmpty ? "ご飯のメモ\n 例） 旬の野菜を取り入れてみました。" : "")
                                .foregroundStyle(Color.gray.opacity(0.5))
                                .padding(5)
                        }
                        .onChange(of: memo) { _ in
                            validateMemo()
                        }
                        .onTapGesture {
                            keybordFocuse.toggle()
                        }
                        .id(1)
                        .onChange(of: keybordFocuse) { _ in
                            withAnimation {
                                reader.scrollTo(1, anchor: .top)
                            }
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolBarBackButtonView {
                        if addPostVM.loadStatus != .loading {
                            if image != nil || !title.isEmpty || !memo.isEmpty {
                                showAlertDialog = true
                            } else {
                                dismiss()
                            }
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("ご飯を投稿")
                        .foregroundStyle(Color.white)
                        .font(.title3)
                        .fontWeight(.bold)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    ToolBarAddButtonView(text: "投稿") {
                        validateTitle()
                        validateMemo()
                        validateImage()
                        if titleErrorMessage.isEmpty &&
                            memoErrorMessage.isEmpty &&
                            image != nil &&
                            addPostVM.loadStatus != .loading {
                            print("ワードチェック完了")
                            Task {
                                guard let dataImage = image?.castToData() else { return }

                                // firebase（PostDataModelとUserPostDataModel）とCoreDataに保存
                                addPostVM.addPost(post: PostElement(
                                    uid: addPostVM.fetchUid(),
                                    postImage: dataImage,
                                    title: title,
                                    memo: memo,
                                    isPrivate: isPrivate,
                                    createAt: Date(),
                                    likeCount: 0,
                                    likedUser: [],
                                    comment: []
                                ))
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
        .interactiveDismissDisabled(isLoading)
    }

    private func validateTitle() {
        titleErrorMessage = ""
        if title.isEmpty {
            titleErrorMessage = "料理名を入力してください"
        } else if title.containsNGWord() {
            titleErrorMessage = "不適切な言葉が含まれています"
        } else if title.count > 15 {
            titleErrorMessage = "料理名は15文字以下で入力してください"
        }
    }

    private func validateMemo() {
        memoErrorMessage = ""
        if memo.containsNGWord() {
            memoErrorMessage = "不適切な言葉が含まれています"
        } else if memo.count > 150 {
            memoErrorMessage = "メモは150文字以下で入力してください"
        }
    }

    private func validateImage() {
        imageErrorMessage = ""
        if image == nil {
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
    AddPostView()
}
