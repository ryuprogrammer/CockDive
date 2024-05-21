import SwiftUI

struct CockPostView: View {
    @State private var showPostsData: [PostElement] = []
    @State private var isShowSheet: Bool = false
    @State private var userFriendData: UserFriendElement? = nil
    @State private var userPostData: UserPostElement? = nil
    
    @ObservedObject var cockPostVM = CockPostViewModel()
    @State var detailPost: PostElement = PostElement(uid: "B4uotKO8WiPsylwU5LYSCYBUPjk2", title: "sss", isPrivate: false, createAt: Date(), likeCount: 10, likedUser: [], comment: [])
    
    @State private var cockCardNavigationPath: [CockCardNavigationPath] = []
    
    @State private var lastPost: PostElement?
    
    var body: some View {
        NavigationStack(path: $cockCardNavigationPath) {
            ZStack {
                ScrollViewReader { proxy in
                    List {
                        ForEach(showPostsData, id: \.id) { postData in
                            CockCardView(showPostData: postData, friendData: userFriendData, path: $cockCardNavigationPath)
                                .id(postData.id)
                                .onAppear {
                                    if cockPostVM.checkIsLastPost(postData: postData) {
                                        Task {
                                            await cockPostVM.fetchMorePosts()
                                        }
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .onChange(of: showPostsData) { _ in
                        if let lastPost = lastPost {
                            proxy.scrollTo(lastPost.id, anchor: .bottom)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
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
        .onChange(of: cockPostVM.newPostsData) { newPostData in
            lastPost = showPostsData.last
            showPostsData.append(contentsOf: newPostData)
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
