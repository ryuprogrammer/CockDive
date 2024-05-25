import SwiftUI

struct ProfileView: View {
    @State var showUser: UserElement
    @State var showIsFollow: Bool

    @ObservedObject var profileVM = ProfileViewModel()
    @StateObject private var hapticsManager = HapticsManager()

    // このViewで取得
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
    // フォローボタン無効状態
    @State private var isFollowButtonDisabled: Bool = false

    // 画面遷移戻る
    @Environment(\.presentationMode) var presentation
    // 画面サイズ取得
    var screenWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.width
        }
        return 400
    }

    var body: some View {
        ScrollView {
            // アイコン、投稿数、フォロー数、フォロワー数
            HStack(spacing: 10) {
                // アイコン画像
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
                .padding(.trailing)
            }
            // 自己紹介文
            DynamicHeightCommentView(message: showUser.introduction ?? "", maxTextCount: 30)
            // フォローボタン
            HStack {
                Spacer()
                // フォローボタン
                Button {
                    // ボタンの無効化
                    isFollowButtonDisabled = true
                    // haptics
                    hapticsManager.playHapticPattern()
                    Task {
                        // フォローデータ更新
                        await profileVM.followUser(friendUid: showUser.id ?? "")
                        // フォローデータ取得
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
                    // 押せない時は少し白くする
                    .foregroundStyle(Color.white.opacity(isFollowButtonDisabled ? 0.7 : 0.0))
                }
                .disabled(isFollowButtonDisabled)
                .buttonStyle(BorderlessButtonStyle())
            }

            // ここで使用
            SwipeableCardView(screenWidth: screenWidth) {
                Group {
                    cardView(text: "Card 1", color: .blue, width: screenWidth)
                    cardView(text: "Card 2", color: .green, width: screenWidth)
                }
            }
        }
        // TabBar非表示
        .toolbar(.hidden, for: .tabBar)
        // 戻るボタン非表示
        .navigationBarBackButtonHidden(true)
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            // 戻るボタン
            ToolbarItem(placement: .topBarLeading) {
                ToolBarBackButtonView {
                    self.presentation.wrappedValue.dismiss()
                }
            }

            // タイトル
            ToolbarItem(placement: .principal) {
                Text(showUser.nickName)
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .font(.title3)
            }

            // 通報
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {

                    } label: {
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
            Task {
                guard let uid = showUser.id else { return }
                await profileVM.fetchUserFriendData(uid: uid)
                await profileVM.fetchUserPostElement(uid: uid)
            }
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

    @ViewBuilder
    private func cardView(text: String, color: Color, width: CGFloat) -> some View {
        Text(text)
            .frame(width: width, height: 200)
            .background(color)
            .cornerRadius(10)
            .padding()
    }
}

struct SwipeableCardView<Content: View>: View {
    let screenWidth: CGFloat
    let content: () -> Content
    @State private var offset: CGFloat = 0
    @State private var currentIndex: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        content()
                            .frame(width: screenWidth, height: geometry.size.height)
                    }
                    .frame(width: screenWidth * 2, height: geometry.size.height)
                }
                .content.offset(x: -CGFloat(currentIndex) * screenWidth + offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.offset = value.translation.width
                        }
                        .onEnded { value in
                            withAnimation {
                                if value.translation.width < -screenWidth / 2 {
                                    currentIndex = 1
                                } else if value.translation.width > screenWidth / 2 {
                                    currentIndex = 0
                                }
                                offset = 0
                            }
                        }
                )
                .onAppear {
                    offset = 0
                }
            }
        }
        .frame(height: 200)
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
