import SwiftUI

struct CockPostView: View {
    // 投稿追加画面の表示有無
    @State private var isShowSheet: Bool = false
    @ObservedObject var cockPostVM = CockPostViewModel()
    // 画面遷移用
    @State private var navigationPath: [CockPostViewPath] = []
    // postDetail用のpostデータ
    @State var detailPost: PostElement = PostElement(uid: "B4uotKO8WiPsylwU5LYSCYBUPjk2", title: "sss", isPrivate: false, createAt: Date(), likeCount: 10, likedUser: [], comment: [])
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                ScrollView {
                    ForEach(cockPostVM.postData, id: \.self) { postData in
                        CockCardView(postData: postData, path: $navigationPath)

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
                    PostDetailView(postData: detailPost, path: $navigationPath)
                }
            }
        }
        .sheet(isPresented: $isShowSheet) {
            AddPostView()
        }
        .onAppear {
            Task {
                await cockPostVM.fetchPost()
            }
        }
    }
}

enum CockPostViewPath {
    case postDetailView
}

#Preview {
    CockPostView(detailPost: PostElement(uid: "", title: "定食", isPrivate: false, createAt: Date(), likeCount: 10, likedUser: [], comment: []))
}
