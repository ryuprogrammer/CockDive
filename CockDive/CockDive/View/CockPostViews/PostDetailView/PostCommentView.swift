import SwiftUI

struct PostCommentView: View {
    let maxTextCount: Int = 50
    @State private var comments: [String] = [
        "美味しそう！",
        "レシピを教えてください！",
        "最長文字数に挑戦中最長文字数に挑戦中最長文字数に挑戦中戦中最長文字数に挑戦中最長文字数に挑戦中最長文字数に挑戦戦中最長文字数に挑戦中最長文字数に挑戦中最長文字数に挑戦戦中最長文字数に挑戦中最長文字数に挑戦中最長文字数に挑戦戦中最長文字数に挑戦中最長文字数に挑戦中最長文字数に挑戦最長文字数に挑戦中最長文字数に挑戦中最長文字数に挑戦中",
        "お腹すいた"
    ]
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    var body: some View {
        ForEach(comments, id: \.self) { comment in
            HStack(alignment: .top) {
                Image("cockImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: (window?.screen.bounds.width ?? 50) / 10,
                        height: (window?.screen.bounds.width ?? 50) / 10
                    )
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("名前")
                        
                        Text(Date().dateString())
                            .font(.caption)
                        
                        Spacer()
                        
                        Menu {
                            Button(action: {
                                
                            }, label: {
                                HStack {
                                    Image(systemName: "nosign")
                                    Spacer()
                                    Text("ブロック")
                                }
                            })
                            
                            Button(action: {
                                
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
                    
                    DynamicHeightCommentView(message: comment, maxTextCount: maxTextCount)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    PostCommentView()
}
