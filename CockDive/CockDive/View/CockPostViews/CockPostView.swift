import SwiftUI

// SwiftUIのViewにUIKitのUITableViewを組み込む
struct CockPostView: View {
    @State private var isShowSheet: Bool = false
    @State private var userFriendData: UserFriendElement? = nil
    @State private var userPostData: UserPostElement? = nil
    
    @ObservedObject var cockPostVM = CockPostViewModel()
    @State var detailPost: PostElement = PostElement(uid: "B4uotKO8WiPsylwU5LYSCYBUPjk2", title: "sss", isPrivate: false, createAt: Date(), likeCount: 10, likedUser: [], comment: [])
    
    @State private var cockCardNavigationPath: [CockCardNavigationPath] = []
    @State private var canLoadPost: Bool = false
    
    // LastPostを保持
    @State var lastPost: PostElement?
    
    var body: some View {
        NavigationStack(path: $cockCardNavigationPath) {
            ZStack {
                ScrollViewReader { reader in
                    List {
                        ForEach(cockPostVM.postsData, id: \.id) { postData in
                            CockCardView(postData: postData, friendData: userFriendData, path: $cockCardNavigationPath)
                                .id(postData.id)
                                .onAppear {
                                    print("レンダリング: \(postData.id ?? "")")
                                    if cockPostVM.checkIsLastPost(postData: postData) {
                                        print("最後のポスト表示: onAppear")
                                        // 最新のポストの最後を保持
                                        lastPost = postData
                                        Task {
                                            await cockPostVM.fetchMorePosts()
                                        }
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .onChange(of: cockPostVM.postsData) { _ in
                        if let post = lastPost {
                            print("スクローーーーーーーーーーーーーる")
                            reader.scrollTo(post.id)
                        }
                    }
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
                        .background(Color.mainColor)
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
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("みんなのごはん")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .font(.title3)
                }
            }
            .navigationDestination(for: CockCardNavigationPath.self) { pathData in
                switch pathData {
                case .detailView(let postData):
                    PostDetailView(postData: postData)
                }
            }
        }
        .sheet(isPresented: $isShowSheet) {
            AddPostView()
        }
        .onAppear {
            Task {
                userFriendData = await cockPostVM.fetchUserFriendElement()
                userPostData = await cockPostVM.fetchUserPostElement()
                await cockPostVM.fetchPosts()
            }
        }
    }
}

enum CockCardNavigationPath: Hashable {
    case detailView(postData: PostElement)
}

#Preview {
    CockPostView(
        detailPost: PostElement(
            uid: "",
            title: "定食",
            isPrivate: false,
            createAt: Date(),
            likeCount: 10,
            likedUser: [],
            comment: []
        )
    )
}

