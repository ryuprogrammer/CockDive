import SwiftUI
import PhotosUI

struct AddPostView: View {
    @StateObject private var cockPostVM = AddPostViewModel()
    @State private var title: String = ""
    @State private var memo: String = ""
    @State private var isPrivate: Bool = true
    @State private var titleErrorMessage = ""
    @State private var memoErrorMessage = ""
    @State private var showErrorDialog = false
    @State private var isPresentedCameraView: Bool = false
    @State private var image: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @FocusState private var keybordFocuse: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollViewReader { reader in
                VStack(spacing: 15) {
                    SectioinTitleView(text: "まずは写真を追加しよう！", isRequired: true)
                        .padding(.top)

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

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
                                    image = cropToRectangle(image: selectedImage)
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
                            .foregroundStyle(Color.red)
                    }

                    Spacer()
                        .frame(height: 10)
                        .listRowSeparator(.hidden)

                    Spacer()
                }
                .padding(.horizontal)
                .overlay {
                    if cockPostVM.loadStatus == .loading {
                        ProgressView("投稿中🥕🥕🥕")
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
                        dismiss()
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
                        print("投稿ボタン押された")
                        validateTitle()
                        validateMemo()
                        if titleErrorMessage.isEmpty && memoErrorMessage.isEmpty {
                            print("ワードチェック完了")
                            Task {
                                guard let dataImage = image?.castToData() else { return }

                                // firebase（PostDataModelとUserPostDataModel）とCoreDataに保存
                                cockPostVM.addPost(post: PostElement(
                                    uid: cockPostVM.fetchUid(),
                                    postImage: dataImage,
                                    title: title,
                                    memo: memo,
                                    isPrivate: isPrivate,
                                    createAt: Date(),
                                    likeCount: 0,
                                    likedUser: [],
                                    comment: []
                                ))

                                if case .error(let errorMessage) = cockPostVM.loadStatus {
                                    showErrorDialog = true
                                } else if case .success = cockPostVM.loadStatus {
                                    dismiss()
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
        .alert(isPresented: $showErrorDialog) {
            Alert(
                title: Text("エラー"),
                message: Text(cockPostVM.loadStatus?.errorDescription ?? "不明なエラーが発生しました"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func validateTitle() {
        titleErrorMessage = ""
        if title.isEmpty {
            titleErrorMessage = "料理名を入力してください"
        } else if title.containsNGWord() {
            titleErrorMessage = "不適切な言葉が含まれています"
        } else if title.count > 15 {
            titleErrorMessage = "料理名は15文字以下で入力してください。"
        }
    }

    private func validateMemo() {
        memoErrorMessage = ""
        if memo.containsNGWord() {
            memoErrorMessage = "不適切な言葉が含まれています"
        } else if memo.count > 150 {
            memoErrorMessage = "メモは150文字以下で入力してください。"
        }
    }

    private func cropToRectangle(image: UIImage) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.width * 2 / 3) // 横長の長方形にトリミング
        guard let cgImage = image.cgImage?.cropping(to: rect) else {
            return image
        }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
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
//            picker.dismiss(animated: true)
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
