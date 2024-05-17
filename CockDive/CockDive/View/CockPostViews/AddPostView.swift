import SwiftUI
import PhotosUI

struct AddPostView: View {
    let cockPostVM = CockPostViewModel()
    @State private var title: String = ""
    @State private var memo: String = ""
    @State private var isPrivate: Bool = true
    
    @State private var isPresentedCameraView: Bool = false
    @State private var image: UIImage?
    // PhotosPickerで選択された写真
    @State private var selectedImage: [PhotosPickerItem] = []
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    // キーボード制御
    @FocusState private var keybordFocuse: Bool
    // モーダル制御
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { reader in
                List {
                    Section {
                        // アルバムから選択
                        PhotosPicker(
                            selection: $selectedImage,
                            maxSelectionCount: 1,
                            matching: .images,
                            preferredItemEncoding: .current,
                            photoLibrary: .shared()) {
                                StrokeIconButtonUI(text: "アルバムから選ぶ", icon: "photo.on.rectangle.angled")
                            }
                            .onChange(of: selectedImage) { newPhotoPickerItems in
                                Task {
                                    guard let uiImage = await cockPostVM.castImageType(images: newPhotoPickerItems) else {
                                        return
                                    }
                                    image = uiImage
                                }
                            }
                        // カメラで撮影
                        Button {
                            isPresentedCameraView = true
                        } label: {
                            StrokeIconButtonUI(text: "写真を撮る", icon: "camera")
                        }
                        
//                        Button(action: {
//                            
//                        }, label: {
//                            Text("写真を追加")
//                                .font(.title)
//                                .fontWeight(.bold)
//                                .foregroundStyle(Color.mainColor)
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 200)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 20)
//                                        .stroke(lineWidth: 2)
//                                        .foregroundStyle(Color.mainColor)
//                                )
//                        })
                    } header: {
                        Text("①写真: まずは写真を追加しよう 必須")
                    }
                    .listRowSeparator(.hidden)
                    
                    Section {
                        TextField("料理名を入力", text: $title)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 0.6)
                            )
                    } header: {
                        Text("②料理名: 何を食べたの？ 必須")
                    }
                    .listRowSeparator(.hidden)
                    
                    Section {
                        TextEditor(text: $memo)
                            .focused($keybordFocuse)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 0.6)
                            )
                            .overlay(alignment: .topLeading) {
                                Text(memo == "" ? "ご飯のメモ\n 例） 旬の野菜を取り入れてみました。" : "")
                                    .foregroundStyle(Color.gray.opacity(0.5))
                                    .padding(5)
                            }
                            .onTapGesture {
                                keybordFocuse.toggle()
                            }
                            .id(1)
                            .onChange(of: keybordFocuse) {_ in
                                withAnimation {
                                    reader.scrollTo(1, anchor: .top)
                                }
                            }
                    } header: {
                        Text("③メモ: ご飯のメモをしよう")
                    }
                    .listRowSeparator(.hidden)
                    
                    Section {
                        Toggle(isPrivate ? "みんなに公開" : "非公開", isOn: $isPrivate)
                            .toggleStyle(.switch)
                    } header: {
                        Text("③公開範囲: 誰に見てもらう？")
                    }
                    .listRowSeparator(.hidden)
                    
                    Spacer()
                        .frame(height: 10)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ご飯を投稿")
                        .foregroundStyle(Color.white)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ToolBarAddButtonView(text: "投稿") {
                        Task {
                            await cockPostVM.addPost(post: PostElement(
                                uid: cockPostVM.fetchUid(),
                                title: title,
                                memo: memo,
                                isPrivate: isPrivate,
                                createAt: Date(),
                                likeCount: 0,
                                likedUser: [],
                                comment: []
                            ))
                        }
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isPresentedCameraView) {
            CameraView(image: $image)
                .ignoresSafeArea(.all)
        }
    }
}

#Preview {
    AddPostView()
}



