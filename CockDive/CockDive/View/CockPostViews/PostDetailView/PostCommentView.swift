import SwiftUI

struct PostCommentView: View {
    let comment: CommentElement
    @State private var showUserData: UserElement? = nil
    @ObservedObject var postCommentVM = PostCommentViewModel()
    // 自分のコメントか
    let isMyComment: Bool
    // ブロック
    let blockAction: () -> Void
    // 通報処理
    let reportAction: () -> Void
    // コメント削除処理
    let deleteAction: () -> Void

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

                    OptionsView(
                        isMyData: isMyComment,
                        isAlwaysWhite: false,
                        isSmall: true,
                        optionType: .comment,
                        blockAction: {
                            blockAction()
                        },
                        reportAction: {
                            reportAction()
                        },
                        editAction: {},
                        deleteAction: {
                            deleteAction()
                        }
                    )
                }
                
                DynamicHeightCommentView(message: comment.comment)
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
        isMyComment: true,
        blockAction: {},
        reportAction: {},
        deleteAction: {}
    )
}
