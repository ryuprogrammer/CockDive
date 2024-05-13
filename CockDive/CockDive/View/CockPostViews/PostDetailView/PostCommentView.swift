import SwiftUI

struct PostCommentView: View {
    @State private var comments: [String] = [
        "美味しそう！",
        "レシピを教えてください！",
        "最長文字数に挑戦中最長文字数に挑戦中最長文字数に挑戦中最長文字数に挑戦中最長文字数に挑戦中最長文字数に挑戦中",
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
                        
                    }
                    Text(comment)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    PostCommentView()
}
