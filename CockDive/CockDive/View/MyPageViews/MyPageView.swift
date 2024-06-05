import SwiftUI

struct MyPageView: View {
    @ObservedObject var myPageVM = MyPageViewModel()
    // UserDefaultsの基本データ（ニックネーム、自己紹介、アイコン）
    @State var showUserData = UserElementForUserDefaults(nickName: "テスト")
    // UserFriendElement（フォロー、フォロワー）
    @State var showFriendData = UserFriendElement(followCount: 0, follow: [], followerCount: 0, follower: [], block: [], blockedByFriend: [])
    // 投稿数
    @State var showMyPostCount: Int = 0

    // MARK: - カレンダー画面
    // 投稿データ: 表示している月の
    @State var showMyPostData: [(day: Int, posts: [MyPostModel])] = []
    // 表示している月
    @State private var showDate: Date = Date()

    // MARK: - 自分の投稿画面用
    @State var showPostListData: [PostElement] = []
    @State private var lastPost: PostElement?

    // MARK: - ライクした投稿画面用
    @State var showLikePostListData: [PostElement] = []
    @State private var lastLikePost: PostElement?

    // 画面遷移用
    @Binding var cockCardNavigationPath: [CockCardNavigationPath]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack(path: $cockCardNavigationPath) {
            VStack {
                MyPageHeaderView(
                    showUserData: $showUserData,
                    postCount: $showMyPostCount,
                    showFriendData: $showFriendData
                )
                .onAppear {
                    print("onAppear")
                    myPageVM.fetchUserData()
                    myPageVM.fetchMyPostCount()
                    Task {
                        await myPageVM.fetchUserFriendElement()
                    }
                }

                SwipeableTabView(tabs: [
                    (title: "カレンダー", view: AnyView(
                        ImageCalendarView(
                            showingDate: $showDate,
                            showMyPostData: $showMyPostData
                        )
                        .onAppear {
                            showMyPostData = myPageVM.fetchMyPostData(date: showDate)
                        }
                    )),
                    (title: "投稿", view: AnyView(
                        myPostListView()
                    )),
                    (title: "いいね", view: AnyView(
                        likePostListView()
                    ))
                ])
            }
            .frame(maxHeight: .infinity)
            .navigationTitle("ごはんのきろく")
            .toolbarColorScheme(.dark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        cockCardNavigationPath.append(.settingView)
                    } label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35)
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .navigationDestination(for: CockCardNavigationPath.self) { pathData in
                switch pathData {
                case .detailView(let postData, let userData, let firstLike, let firstFollow, let parentViewType):
                    if parentViewType == .myPost {
                        PostDetailView(
                            showPostData: postData,
                            showUserData: userData,
                            showIsLike: firstLike,
                            showIsFollow: firstFollow,
                            cockCardNavigationPath: $cockCardNavigationPath,
                            parentViewPosts: $showPostListData
                        )
                    } else if parentViewType == .likePost {
                        PostDetailView(
                            showPostData: postData,
                            showUserData: userData,
                            showIsLike: firstLike,
                            showIsFollow: firstFollow,
                            cockCardNavigationPath: $cockCardNavigationPath,
                            parentViewPosts: $showLikePostListData
                        )
                    }
                case .profileView(let userData, let showIsFollow):
                    ProfileView(showUser: userData, showIsFollow: showIsFollow, navigationPath: $cockCardNavigationPath)
                case .settingView:
                    SettingView(path: $cockCardNavigationPath)
                case .newsView:
                    NewsView(path: $cockCardNavigationPath)
                case .privacyPolicyView:
                    PrivacyPolicyView(path: $cockCardNavigationPath)
                case .termsOfServiceView:
                    TermsOfServiceView(path: $cockCardNavigationPath)
                case .blockListView:
                    BlockListView(path: $cockCardNavigationPath)
                case .contactView:
                    ContactView(path: $cockCardNavigationPath)
                case .logoutView:
                    LogoutView(path: $cockCardNavigationPath)
                case .deleteAccountView:
                    DeleteAccountView(path: $cockCardNavigationPath)
                }
            }
        }
        .onChange(of: myPageVM.userData) { userData in
            if let userData {
                showUserData = userData
            }
        }
        .onChange(of: myPageVM.friendData) { friendData in
            if let friendData {
                showFriendData = friendData
            }
        }
        .onChange(of: myPageVM.myPostCount) { myPostCount in
            showMyPostCount = myPostCount
        }
        .onChange(of: showDate) { newDate in
            showMyPostData = myPageVM.fetchMyPostData(date: newDate)
        }
    }

    // 自分の投稿リスト
    @ViewBuilder
    func myPostListView() -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                Spacer().frame(height: 3)

                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(showPostListData, id: \.id) { postData in
                        CockCardView(
                            showPostData: postData,
                            isShowUserNameAndFollowButton: false,
                            path: $cockCardNavigationPath,
                            parendViewType: .myPost,
                            deletePostAction: {
                                if postData.uid == myPageVM.fetchUid() {
                                    Task {
                                        await myPageVM.deletePost(postId: postData.id)
                                        showLikePostListData.removeAll(where: {$0.id == postData.id})
                                    }
                                }
                            }
                        )
                        .id(postData.id)
                        .onAppear {
                            if myPageVM.checkIsLastMyPost(postData: postData) {
                                Task {
                                    guard let last = showPostListData.last,
                                          let lastId = last.id else { return }
                                    await myPageVM.fetchMyPostsDataByStatus(
                                        lastId: lastId
                                    )
                                }
                            }
                        }
                    }
                }

                if myPageVM.loadStatusMyPost == .loading {
                    HStack {
                        Spacer()
                        LoadingAnimationView()
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 3)
            .onChange(of: showPostListData) { _ in
                if let lastPost = lastPost {
                    proxy.scrollTo(lastPost.id, anchor: .bottom)
                }
            }
            .onAppear {
                Task {
                    if myPageVM.loadStatusMyPost == .initial {
                        await myPageVM.fetchMyPostsDataByStatus(lastId: nil)
                    }
                }
            }
            .refreshable {
                myPageVM.loadStatusMyPost = .initial
                showPostListData.removeAll()
                myPageVM.newMyPostListData.removeAll()
                Task {
                    await myPageVM.fetchMyPostsDataByStatus(lastId: nil)
                }
            }
            .onChange(of: myPageVM.newMyPostListData) { newPost in
                // データを画面に描画
                showPostListData.append(contentsOf: newPost)
            }
        }
    }

    // ライクした投稿リスト
    @ViewBuilder
    func likePostListView() -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                Spacer().frame(height: 3)

                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(showLikePostListData, id: \.id) { postData in
                        CockCardView(
                            showPostData: postData,
                            isShowUserNameAndFollowButton: true,
                            path: $cockCardNavigationPath,
                            parendViewType: .likePost,
                            deletePostAction: {
                                if postData.uid == myPageVM.fetchUid() {
                                    Task {
                                        await myPageVM.deletePost(postId: postData.id)
                                        showLikePostListData.removeAll(where: {$0.id == postData.id})
                                    }
                                }
                            }
                        )
                        .id(postData.id)
                        .onAppear {
                            if myPageVM.checkIsLastLikePost(postData: postData) {
                                Task {
                                    await myPageVM.fetchLikePostsDataByStatus()
                                }
                            }
                        }
                    }
                }

                if myPageVM.loadStatusLikePost == .loading {
                    HStack {
                        Spacer()
                        LoadingAnimationView()
                        Spacer()
                    }
                }
            }
            .onChange(of: showLikePostListData) { _ in
                if let lastLikePost = lastLikePost {
                    proxy.scrollTo(lastLikePost.id, anchor: .bottom)
                }
            }
            .onAppear {
                Task {
                    if myPageVM.loadStatusLikePost == .initial {
                        await myPageVM.fetchLikePostsDataByStatus()
                    }
                }
            }
            .refreshable {
                myPageVM.loadStatusLikePost = .initial
                showLikePostListData.removeAll()
                myPageVM.newLikePostListData.removeAll()
                Task {
                    await myPageVM.fetchLikePostsDataByStatus()
                }
            }
            .onChange(of: myPageVM.newLikePostListData) { newPost in
                // データを画面に描画
                showLikePostListData.append(contentsOf: newPost)
            }
        }
    }
}

#Preview {
    MyPageView(cockCardNavigationPath: .constant([]))
}
