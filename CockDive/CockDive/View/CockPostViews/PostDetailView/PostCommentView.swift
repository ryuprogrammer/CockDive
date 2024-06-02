import SwiftUI

struct PostCommentView: View {
    let maxTextCount: Int = 50
    let comment: CommentElement
    @State private var showUserData: UserElement? = nil
    @ObservedObject var postCommentVM = PostCommentViewModel()

    // ブロック
    let blockAction: () -> Void
    // 通報処理
    let reportAction: () -> Void

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
        HStack(alignment: .top) {
            // アイコン写真
            ImageView(
                data: showUserData?.iconImage,
                urlString: showUserData?.iconURL,
                imageType: .icon
            )
            .frame(width: screenWidth / 10, height: screenWidth / 10)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                HStack {
                    Text(showUserData?.nickName ?? "ニックネーム")

                    Text(comment.createAt.dateString())
                        .font(.caption)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            blockAction()
                        }, label: {
                            HStack {
                                Image(systemName: "nosign")
                                Spacer()
                                Text("ブロック")
                            }
                        })
                        
                        Button(action: {
                            reportAction()
                        }, label: {
                            HStack {
                                Image(systemName: "exclamationmark.bubble")
                                Spacer()
                                Text("通報")
                            }
                        })
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.black)
                            .frame(width: 20, height: 20)
                    }
                }
                
                DynamicHeightCommentView(message: comment.comment, maxTextCount: maxTextCount)
            }
            
            Spacer()
        }
        .onAppear {
            Task {
                await postCommentVM.fetchUserData(uid: comment.uid)
                showUserData = postCommentVM.userData
            }
        }
    }
}

#Preview {
    PostCommentView(
        comment: CommentElement(uid: "aaa", comment: "美味しそう", createAt: Date()),
        blockAction: {},
        reportAction: {}
    )
}
