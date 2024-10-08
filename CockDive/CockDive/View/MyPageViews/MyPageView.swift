import SwiftUI

struct MyPageView: View {
    @ObservedObject var myPageVM = MyPageViewModel()
    // UserDefaultsの基本データ（ニックネーム、自己紹介、アイコン）
    @State var showUserData = UserElementForUserDefaults(nickName: "なまえ", introduction: "自己紹介自己紹介自己紹介自己紹介自己紹介自己紹介自己紹介自己紹介自己紹介自己紹介自己紹介自己紹介")
    // UserFriendElement（フォロー、フォロワー）
    @State var showFriendData = UserFriendElement(followCount: 0, follow: [], followerCount: 0, follower: [], block: [], blockedByFriend: [])
    // 投稿数
    @State var showMyPostCount: Int = 0

    // MARK: - カレンダー画面
    // 投稿データ: 表示している月の
    @State var showMyPostData: [(day: Int, posts: [MyPostModel])] = []
    // 表示している月
    @State private var showDate: Date = Date()

    // 投稿を編集
    @State private var editPost: PostElement? = nil

    // MARK: - 自分の投稿画面用
    @State var showPostListData: [PostElement] = []
    @State private var lastPost: PostElement?

    // MARK: - ライクした投稿画面用
    @State var showLikePostListData: [PostElement] = []
    @State private var lastLikePost: PostElement?

    @AppStorage("isShowFullCalender") var isShowFullCalender: Bool = true

    // 画面遷移用
    @Binding var cockCardNavigationPath: [CockCardNavigationPath]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack(path: $cockCardNavigationPath) {
            ZStack {
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
                                .onChange(of: showDate) { newDate in
                                    showMyPostData = myPageVM.fetchMyPostData(date: newDate)
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

                if isShowFullCalender {
                    Color.black.opacity(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        Spacer()

                        Text("カレンダーをご飯で埋め尽くそう！")
                            .font(.mainFont(size: 23))
                            .foregroundStyle(Color.white)

                        Image("fullCalender")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 50)
                            .frame(maxWidth: .infinity)

                        Text("閉じる")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .foregroundColor(.white)
                            .padding(.vertical, 10)

                        Spacer()
                    }
                    .onTapGesture {
                        withAnimation {
                            isShowFullCalender = false
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .navigationTitle("\(showUserData.nickName)のきろく")
            .toolbarColorScheme(.dark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowFullCalender.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 33)
                            .foregroundStyle(Color.white)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        cockCardNavigationPath.append(.settingView)
                    } label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 33)
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
                case .mainColorEditView:
                    MainColorEditView(path: $cockCardNavigationPath)
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
        .sheet(item: $editPost) { post in
            AddPostView(
                postType: .edit,
                editPost: post
            )
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
        .onAppear {
            FirebaseLog.shared.logScreenView(.myPageView)
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
                            },
                            editPostAction: { editPost in
                                self.editPost = editPost
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
                FirebaseLog.shared.logScreenView(.myPostView)
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
                            },
                            editPostAction: { editPost in
                                self.editPost = editPost
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
                FirebaseLog.shared.logScreenView(.myLikeView)
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
