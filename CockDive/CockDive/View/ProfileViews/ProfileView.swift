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

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ProfileHeaderView(
                    showUser: showUser,
                    showUserFriends: showUserFriends,
                    showUserPosts: showUserPosts,
                    screenWidth: screenWidth
                )
                .listRowSeparator(.hidden)

                DynamicHeightCommentView(message: showUser.introduction ?? "", maxTextCount: 30)
                    .padding(.horizontal)
                    .listRowSeparator(.hidden)

                FollowButtonView(
                    showIsFollow: $showIsFollow,
                    isFollowButtonDisabled: $isFollowButtonDisabled,
                    hapticsManager: hapticsManager,
                    profileVM: profileVM,
                    showUser: showUser
                )
                .padding(.horizontal)
                .listRowSeparator(.hidden)

                Divider()
                    .listRowSeparator(.hidden)

                ForEach(showPostsData, id: \.id) { postData in
                    PostView(postData: postData)
                        .id(postData.id)
                        .onAppear {
                            if profileVM.checkIsLastPost(postData: postData) {
                                Task {
                                    print("更新！！！！！！！！！！！")
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
                .onChange(of: showPostsData) { _ in
                    if let lastPost = lastPost {
                        proxy.scrollTo(lastPost.id, anchor: .center)
                    }
                }
            }
        }
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
            print("newPostData: \(newPostData.count)")
            lastPost = showPostsData.last
            showPostsData.append(contentsOf: newPostData)
            print("showPostsData: \(showPostsData.count)")
        }
        .onChange(of: profileVM.userFriends) { userFriends in
            if let userFriends {
                print("userFriends: \(userFriends)")
                showUserFriends = userFriends
            }
        }
        .onChange(of: profileVM.userPosts) { userPosts in
            if let userPosts {
                print("userPosts: \(userPosts)")
                showUserPosts = userPosts
            }
        }
        .onChange(of: profileVM.isFollow) { isFollow in
            showIsFollow = isFollow
        }
    }
}

struct ProfileHeaderView: View {
    var showUser: UserElement
    var showUserFriends: UserFriendElement
    var showUserPosts: UserPostElement
    var screenWidth: CGFloat

    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            if let data = showUser.iconImage,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.gray)
                    .frame(width: screenWidth / 6, height: screenWidth / 6)
                    .padding()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.gray)
                    .frame(width: screenWidth / 6, height: screenWidth / 6)
                    .padding()
            }
            Spacer()
            VStack {
                Text("\(showUserPosts.postCount)")
                Text("投稿")
            }
            VStack {
                Text("\(showUserFriends.followCount)")
                Text("フォロー")
            }
            VStack {
                Text("\(showUserFriends.followerCount)")
                Text("フォロワー")
            }
            Spacer()
        }
    }
}

struct FollowButtonView: View {
    @Binding var showIsFollow: Bool
    @Binding var isFollowButtonDisabled: Bool
    var hapticsManager: HapticsManager
    var profileVM: ProfileViewModel
    var showUser: UserElement

    var body: some View {
        HStack {
            Spacer()
            Button {
                isFollowButtonDisabled = true
                hapticsManager.playHapticPattern()
                Task {
                    await profileVM.followUser(friendUid: showUser.id ?? "")
                    profileVM.checkIsFollow(friendUid: showUser.id ?? "")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isFollowButtonDisabled = false
                }
            } label: {
                StrokeButtonUI(
                    text: showIsFollow ? "フォロー中" : "フォロー" ,
                    size: .small,
                    isFill: showIsFollow ? true : false
                )
                .foregroundStyle(Color.white.opacity(isFollowButtonDisabled ? 0.7 : 0.0))
            }
            .disabled(isFollowButtonDisabled)
            .buttonStyle(BorderlessButtonStyle())
            .padding(.trailing)
        }
    }
}

struct PostView: View {
    var postData: PostElement

    var body: some View {
        Text("postData: \(postData.title)")
            .font(.largeTitle)
            .frame(width: 400, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 20))
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
            showIsFollow: false
        )
    }
}
