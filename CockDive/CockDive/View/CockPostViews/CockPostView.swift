import SwiftUI
import CoreData

struct CockPostView: View {
    @State private var showPostsData: [PostElement] = []
    @State private var isShowSheet: Bool = false
    @State private var userFriendData: UserFriendElement? = nil

    @ObservedObject var cockPostVM = CockPostViewModel()

    @Binding var cockCardNavigationPath: [CockCardNavigationPath]

    @State private var lastPost: PostElement?

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack(path: $cockCardNavigationPath) {
            ZStack {
                if showPostsData.isEmpty {
                    LoadingAnimationView()
                } else {
                    postListView
                }
                addButton
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
                case .detailView(let postData, let firstLike, let firstFollow):
                    PostDetailView(showPostData: postData, showIsLike: firstLike, showIsFollow: firstFollow)
                case .profileView(let userData, let isFollow):
                    ProfileView(showUser: userData, showIsFollow: isFollow, navigationPath: $cockCardNavigationPath)
                default:
                    EmptyView()
                }
            }
        }
        .sheet(isPresented: $isShowSheet) {
            AddPostView()
                .onDisappear {
                    cockPostVM.loadStatus = .initial
                    showPostsData.removeAll()
                    cockPostVM.newPostsData.removeAll()
                    Task {
                        await cockPostVM.fetchPostsDataByStatus()
                    }
                }
        }
        .onChange(of: cockPostVM.newPostsData) { newPostData in
            lastPost = showPostsData.last
            showPostsData.append(contentsOf: newPostData)
        }
        .onAppear {
            if cockPostVM.loadStatus == .initial {
                Task {
                    await cockPostVM.fetchPostsDataByStatus()
                }
            }
        }
    }

    private var postListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Spacer().frame(height: 3)
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(showPostsData, id: \.id) { postData in
                        CockCardView(
                            showPostData: postData,
                            path: $cockCardNavigationPath,
                            isShowUserNameAndFollowButton: true
                        )
                        .id(postData.id)
                        .onAppear {
                            if cockPostVM.checkIsLastPost(postData: postData) {
                                Task {
                                    await cockPostVM.fetchPostsDataByStatus()
                                }
                            }
                        }
                    }

                    if cockPostVM.loadStatus == .loading {
                        HStack {
                            Spacer()
                            LoadingAnimationView()
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, 3)
            .onChange(of: showPostsData) { _ in
                if let lastPost = lastPost {
                    proxy.scrollTo(lastPost.id, anchor: .center)
                }
            }
            .refreshable {
                cockPostVM.loadStatus = .initial
                showPostsData.removeAll()
                cockPostVM.newPostsData.removeAll()
                Task {
                    await cockPostVM.fetchPostsDataByStatus()
                }
            }
        }
    }


    private var addButton: some View {
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
}

#Preview {
    CockPostView(cockCardNavigationPath: .constant([]))
}
