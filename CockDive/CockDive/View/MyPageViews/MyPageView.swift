import SwiftUI

struct MyPageView: View {
    @ObservedObject var myPageVM = MyPageViewModel()
    // UserDefaultsの基本データ（ニックネーム、自己紹介、アイコン）
    @State var showUserData = UserElementForUserDefaults(nickName: "テスト")
    // UserFriendElement（フォロー、フォロワー）
    @State var showFriendData = UserFriendElement(followCount: 0, follow: [], followerCount: 0, follower: [], block: [], blockedByFriend: [])
    // 投稿数
    @State var showMyPostCount: Int = 0

    // MARK: - 自分の投稿画面
    @State var showPostListData: [PostElement] = []
    @State private var lastPost: PostElement?

    // MARK: - カレンダー画面
    // 投稿データ: 表示している月の
    @State var showMyPostData: [(day: Int, posts: [MyPostModel])] = []
    // 表示している月
    @State private var showDate: Date = Date()

    // 画面遷移用
    @Binding var cockCardNavigationPath: [CockCardNavigationPath]

    var body: some View {
        NavigationStack(path: $cockCardNavigationPath) {
            VStack {
                MyPageHeaderView(
                    showUserData: $showUserData,
                    postCount: $showMyPostCount,
                    showFriendData: $showFriendData
                )

                SwipeableTabView(tabs: [
                    (title: "カレンダー", view: AnyView(
                        ImageCalendarView(showingDate: $showDate, showMyPostData: $showMyPostData)
                    )),
                    (title: "投稿", view: AnyView(
                        postListView()
                    )),
                    (title: "いいね", view: AnyView(
                        Text("いいね")
                    ))
                ])
            }
            .frame(maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("マイページ")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .font(.title3)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingView()
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
                case .detailView(let postData, let firstLike, let firstFollow):
                    PostDetailView(showPostData: postData, showIsLike: firstLike, showIsFollow: firstFollow)
                case .profileView(let userData, let showIsFollow):
                    ProfileView(showUser: userData, showIsFollow: showIsFollow, navigationPath: $cockCardNavigationPath)
                }
            }
        }
        .onAppear {
            myPageVM.fetchUserData()
            showMyPostData = myPageVM.fetchMyPostData(date: showDate)
            myPageVM.fetchMyPostCount()
            Task {
                await myPageVM.fetchUserFriendElement()
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
        .onChange(of: myPageVM.newMyPostListData) { newPost in
            showPostListData.append(contentsOf: newPost)
        }
    }

    @ViewBuilder
    func postListView() -> some View {
        ScrollViewReader { proxy in
            List {
                ForEach(showPostListData, id: \.id) { postData in
                    CockCardView(
                        showPostData: postData,
                        path: $cockCardNavigationPath,
                        isShowUserNameAndFollowButton: false
                    )
                    .id(postData.id)
                    .onAppear {
                        if myPageVM.checkIsLastPost(postData: postData) {
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
                .listRowSeparator(.hidden)
                .onChange(of: showPostListData) { _ in
                    if let lastPost = lastPost {
                        proxy.scrollTo(lastPost.id, anchor: .bottom)
                    }
                }
            }
            .listStyle(.plain)
            .onAppear {
                Task {
                    if myPageVM.loadStatusMyPost == .initial {
                        await myPageVM.fetchMyPostsDataByStatus(lastId: nil)
                    }
                }
            }
        }
    }
}

#Preview {
    MyPageView(cockCardNavigationPath: .constant([]))
}
