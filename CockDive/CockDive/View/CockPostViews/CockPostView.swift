import SwiftUI

struct CockPostView: View {
    // 投稿追加画面の表示有無
    @State private var isShowSheet: Bool = false
    
    // 画面遷移用
    @State private var navigationPath: [CockPostViewPath] = []
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                ScrollView {
                    ForEach(0..<10) { _ in
                        CockCardView(path: $navigationPath)
                    }
                    .padding()
                }
                
                Button(action: {
                    isShowSheet = true
                }, label: {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: 65, height: 65)
                        .foregroundStyle(Color.white)
                        .background(Color("main"))
                        .clipShape(Circle())
                })
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottomTrailing
                )
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("main"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("みんなのご飯")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .font(.title3)
                }
            }
            
            .navigationDestination(for: CockPostViewPath.self) { value in
                switch value {
                case .postDetailView:
                    PostDetailView(path: $navigationPath)
                }
            }
        }
        .sheet(isPresented: $isShowSheet) {
            AddPostView()
        }
    }
}

enum CockPostViewPath {
    case postDetailView
}

#Preview {
    CockPostView()
}

