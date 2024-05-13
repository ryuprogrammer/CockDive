import SwiftUI

struct PostDetailView: View {
    @State private var userName: String = "momo"
    @State private var title: String = "定食"
    @State private var explain: String = """
ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入ここに説明文を挿入
"""
    
    @State private var isLike: Bool = false
    @State private var likeCount: Int = 200
    
    var body: some View {
        List {
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
                
                Text(explain)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("main"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .font(.title3)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35)
                        .foregroundStyle(Color.white)
                })
            }
        }
    }
}

#Preview {
    PostDetailView()
}
