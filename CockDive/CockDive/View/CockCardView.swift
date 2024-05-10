import SwiftUI

struct CockCardView: View {
    @State private var userName: String = "momo"
    @State private var title: String = "定食"
    @State private var explain: String = """
ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入
"""
    
    @State private var isLike: Bool = false
    @State private var likeCount: Int = 200
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(title)
                    .font(.title)
                Text("\(userName)さん")
                
                Button(action: {
                    
                }, label: {
                    Text("フォロー")
                        .font(.callout)
                        .padding(.horizontal, 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                })
                Spacer()
                
                Image(systemName: "ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .foregroundStyle(Color.primary)
            }
            
            ZStack {
                Image("cockImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            HStack {
                Text(explain)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
        .padding(.horizontal)
    }
}

#Preview {
    CockCardView()
}
