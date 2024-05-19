import SwiftUI

struct PostCommentView: View {
    let maxTextCount: Int = 50
    let comment: CommentElement
    
    // ブロック
    let blockAction: () -> Void
    // 通報処理
    let reportAction: () -> Void
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    var body: some View {
        HStack(alignment: .top) {
            // アイコン写真のURL
            let imageURL = URL(string: comment.commentUserIconURL ?? "")
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: (window?.screen.bounds.width ?? 50) / 10,
                        height: (window?.screen.bounds.width ?? 50) / 10
                    )
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: (window?.screen.bounds.width ?? 50) / 10,
                        height: (window?.screen.bounds.width ?? 50) / 10
                    )
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.commentUserNickName ?? "ユーザー")
                    
                    Text(Date().dateString())
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
    }
}

#Preview {
    PostCommentView(
        comment: CommentElement(uid: "aaa", comment: "美味しそう", createAt: Date()),
        blockAction: {},
        reportAction: {}
    )
}
