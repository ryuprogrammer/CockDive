import SwiftUI

struct CockCardView: View {
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
                
                StrokeButton(text: "フォロー") {
                    
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .foregroundStyle(Color.primary)
            }
            
            Image("cockImage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            HStack {
                VStack {
                    Text(explain)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(isLineLimit ? 2 : nil)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            
                        }, label: {
                            Text("...続きを読む")
                                .foregroundStyle(Color.black)
                        })
                    }
                }
                
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
