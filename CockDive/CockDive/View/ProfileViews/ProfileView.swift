import SwiftUI

struct ProfileView: View {
    @State var showUser: UserElement
    @State var showIsFollow: Bool
    @State var showPostsData: [PostElement] = []
    @ObservedObject var profileVM = ProfileViewModel()
    @StateObject private var hapticsManager = HapticsManager()
    @State private var lastPost: PostElement?
    @State private var showUserFriends: UserFriendElement = UserFriendElement(
        followCount: 0,
        follow: [],
        followerCount: 0,
        follower: [],
        block: [],
        blockedByFriend: []
    )
    @State private var showUserPosts: UserPostElement = UserPostElement(
        postCount: 0,
        posts: [],
        likePostCount: 0,
        likePost: []
    )
    @State private var isFollowButtonDisabled: Bool = false
    @Environment(\.presentationMode) var presentation

    var screenWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.width
        }
        return 400
    }

    @Binding var navigationPath: [CockCardNavigationPath]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ProfileHeaderView(
                    showUser: $showUser,
                    showUserFriends: $showUserFriends,
                    showUserPosts: $showUserPosts
                )

                if let introduction = showUser.introduction {
                    DynamicHeightCommentView(message: introduction, maxTextCount: 30)
                }

                FollowButtonView(
                    showIsFollow: $showIsFollow,
                    isFollowButtonDisabled: $isFollowButtonDisabled,
                    hapticsManager: hapticsManager,
                    profileVM: profileVM,
                    showUser: showUser
                )

                Divider()
                    .frame(height: 1)
                    .padding(0)
                    .listRowSeparator(.hidden)

                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(showPostsData, id: \.id) { postData in
                        CockCardView(
                            showPostData: postData,
                            path: $navigationPath,
                            isShowUserNameAndFollowButton: false
                        )
                        .id(postData.id)
                        .onAppear {
                            if profileVM.checkIsLastPost(postData: postData) {
                                Task {
                                    guard let last = showPostsData.last,
                                          let lastId = last.id else { return }
                                    await profileVM.fetchPostsDataByStatus(
                                        uid: postData.uid,
                                        lastId: lastId
                                    )
                                }
                            }
                        }
                    }
                }

                if profileVM.loadStatus == .loading || profileVM.loadStatus == .initial {
                    HStack {
                        Spacer()
                        LoadingAnimationView()
                        Spacer()
                    }
                }
            }
            .padding(3)
            .refreshable {
                profileVM.loadStatus = .initial
                showPostsData.removeAll()
                profileVM.newPostsData.removeAll()
                lastPost = nil
                Task {
                    guard let uid = showUser.id else { return }
                    await profileVM.fetchPostFromUid(uid: uid)
                    await profileVM.fetchUserFriendData(uid: uid)
                    await profileVM.fetchUserPostElement(uid: uid)
                }
            }
            .onChange(of: showPostsData) { newShowPostsData in
                if let lastPost = lastPost {
                    proxy.scrollTo(lastPost.id, anchor: .bottom)
                } else {
                    lastPost = newShowPostsData.last
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ToolBarBackButtonView {
                    self.presentation.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .principal) {
                Text(showUser.nickName)
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .font(.title3)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25)
                            .foregroundStyle(Color.white)
                        Text("通報する")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25)
                        .foregroundStyle(Color.white)
                }
            }
        }
        .onAppear {
            if profileVM.loadStatus == .initial {
                Task {
                    guard let uid = showUser.id else { return }
                    await profileVM.fetchPostFromUid(uid: uid)
                    await profileVM.fetchUserFriendData(uid: uid)
                    await profileVM.fetchUserPostElement(uid: uid)
                }
            }
        }
        .onChange(of: profileVM.newPostsData) { newPostData in
            showPostsData.append(contentsOf: newPostData)
        }
        .onChange(of: profileVM.userFriends) { userFriends in
            if let userFriends {
                showUserFriends = userFriends
            }
        }
        .onChange(of: profileVM.userPosts) { userPosts in
            if let userPosts {
                showUserPosts = userPosts
            }
        }
        .onChange(of: profileVM.isFollow) { isFollow in
            showIsFollow = isFollow
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            showUser: UserElement(
                nickName: "John Doe",
                introduction: "自己紹介文自己紹介文自己紹介文自己紹介文自己紹介文自己紹介文自己紹介文",
                iconImage: nil,
                iconURL: nil
            ),
            showIsFollow: false,
            navigationPath: .constant([])
        )
    }
}
