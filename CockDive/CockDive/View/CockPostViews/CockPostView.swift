import SwiftUI
import CoreData

struct CockPostView: View {
    @State private var showPostsData: [PostElement] = []
    @State private var isShowSheet: Bool = false
    @State private var userFriendData: UserFriendElement? = nil

    @ObservedObject var cockPostVM = CockPostViewModel()

    @State private var cockCardNavigationPath: [CockCardNavigationPath] = []

    @State private var lastPost: PostElement?

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
                    ProfileView(showUser: userData, showIsFollow: isFollow)
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
            print("loadStatus: \(cockPostVM.loadStatus)")
            if cockPostVM.loadStatus == .initial {
                print("最初の更新！")
                Task {
                    await cockPostVM.fetchPostsDataByStatus()
                }
            }
        }
    }

    private var postListView: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(showPostsData, id: \.id) { postData in
                    CockCardView(
                        showPostData: postData,
                        path: $cockCardNavigationPath
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
                .listRowSeparator(.hidden)

                if cockPostVM.loadStatus == .loading {
                    HStack {
                        Spacer()
                        LoadingAnimationView()
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
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

enum CockCardNavigationPath: Hashable {
    case detailView(postData: PostElement, firstLike: Bool, firstFollow: Bool)
    case profileView(userData: UserElement, showIsFollow: Bool)
}

#Preview {
    CockPostView()
}
