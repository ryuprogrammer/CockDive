import SwiftUI

struct CockPostView: View {
    // 投稿追加画面の表示有無
    @State private var isShowSheet: Bool = false
    // CockCardに渡すUserFriendData
    @State private var userFriendData: UserFriendElement? = nil
    // CockCardに渡すUserPostElement
    @State private var userPostData: UserPostElement? = nil
    
    @ObservedObject var cockPostVM = CockPostViewModel()
    // postDetail用のpostデータ
    @State var detailPost: PostElement = PostElement(uid: "B4uotKO8WiPsylwU5LYSCYBUPjk2", title: "sss", isPrivate: false, createAt: Date(), likeCount: 10, likedUser: [], comment: [])
    
    @State private var navigationPath: [PostElement] = []
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                List(cockPostVM.postData, id: \.id) { postData in
                    CockCardView(postData: postData, userFriendData: userFriendData, userPostData: userPostData, path: $navigationPath)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                
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
            .navigationDestination(for: PostElement.self) { postData in
                PostDetailView(postData: postData)
            }
        }
        .sheet(isPresented: $isShowSheet) {
            AddPostView()
        }
        .onAppear {
            Task {
                userFriendData = await cockPostVM.fetchUserFriendElement()
                userPostData = await cockPostVM.fetchUserPostElement()
                await cockPostVM.fetchPost()
            }
        }
    }
}

#Preview {
    CockPostView(detailPost: PostElement(uid: "", title: "定食", isPrivate: false, createAt: Date(), likeCount: 10, likedUser: [], comment: []))
}
