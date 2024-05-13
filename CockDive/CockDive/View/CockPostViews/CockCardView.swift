import SwiftUI

struct CockCardView: View {
    let maxTextCount = 15
    @State private var userName: String = "momo"
    @State private var title: String = "定食"
    @State private var explain: String = """
ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入
"""
    
    @State private var isLike: Bool = false
    @State private var likeCount: Int = 200
    
    // 続きを読む
    @State private var isLineLimit: Bool = false
    
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockPostViewPath]
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title)
                Text("\(userName)さん")
                
                Image(systemName: "ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .foregroundStyle(Color.primary)
                Spacer()
                StrokeButton(text: "フォロー") {
                    
                }
            }
            
            Image("cockImage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            HStack {
                DynamicHeightCommentView(message: explain, maxTextCount: maxTextCount)
                
                VStack(spacing: 1) {
                    Image(systemName: isLike ? "heart" : "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25)
                        .foregroundStyle(Color.pink)
                        .onTapGesture {
                            withAnimation {
                                isLike.toggle()
                                if isLike == true {
                                    likeCount -= 1
                                } else {
                                    likeCount += 1
                                }
                            }
                        }
                    
                    Text(String(likeCount))
                        .font(.footnote)
                }
            }
        }
        .onTapGesture {
            path.append(.postDetailView)
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State private var path: [CockPostViewPath] = []
        
        var body: some View {
            CockCardView(path: $path)
        }
    }
    return PreviewView()
}
