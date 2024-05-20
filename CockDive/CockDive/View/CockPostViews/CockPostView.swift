import SwiftUI

struct CockPostView: View {
    // 投稿追加画面の表示有無
    @State private var isShowSheet: Bool = false
    // CockCardに渡すUserFriendData
    @State private var userFriendData: UserFriendElement? = nil
    // CockCardに渡すUserPostElement
    @State private var userPostData: UserPostElement? = nil
    
    @ObservedObject var cockPostVM = CockPostViewModel()
    // postDetail用のpostデータ
    @State var detailPost: PostElement = PostElement(uid: "B4uotKO8WiPsylwU5LYSCYBUPjk2", title: "sss", isPrivate: false, createAt: Date(), likeCount: 10, likedUser: [], comment: [])
    
    @State private var navigationPath: [PostElement] = []
    // PostDataのリロードを許可
    @State private var canLoadPost: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                ScrollViewReader { proxy in
                    List {
                        ForEach(cockPostVM.postData, id: \.id) { postData in
                            let isFollow = cockPostVM.checkIsFollow(userFriendData: userFriendData, friendUid: postData.uid)
                            let isLike = cockPostVM.checkIsLike(postData: postData)
                            
                            CockCardView(postData: postData, isFollow: isFollow, isLike: isLike, path: $navigationPath)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .background(
                        GeometryReader { proxy -> Color in
                            DispatchQueue.main.async {
                                let maxY = proxy.frame(in: .global).maxY
                                let threshold = UIScreen.main.bounds.height
                                if maxY < threshold {
                                    print("下まで到達！！！！！！！！！")
                                    if canLoadPost {
                                        print("リローーーーーーーーど！！")
                                        Task {
                                            await cockPostVM.fetchMorePostIds()
                                        }
                                        canLoadPost = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            canLoadPost = true
                                        }
                                    } else {
                                        print("到達したけどロードできない。。。。。。。")
                                    }
                                }
                            }
                            return Color.clear
                        }
                    )
                    .listStyle(.plain)
//                    .onChange(of: cockPostVM.postData) { _ in
//                        if let lastPost = cockPostVM.postData.last {
//                            proxy.scrollTo(lastPost.id, anchor: .bottom)
//                        }
//                    }
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
                    Text("みんなのご飯")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .font(.title3)
                }
            }
            .navigationDestination(for: PostElement.self) { postData in
                PostDetailView(postData: postData)
            }
        }
        .sheet(isPresented: $isShowSheet) {
            AddPostView()
        }
        .onAppear {
            Task {
                userFriendData = await cockPostVM.fetchUserFriendElement()
                userPostData = await cockPostVM.fetchUserPostElement()
                await cockPostVM.fetchPostIds()
            }
        }
        .onChange(of: cockPostVM.postIds) { postIds in
            // postIdを使用して、Postをリッスン開始
            cockPostVM.listenToPosts(postIds: postIds)
        }
    }
}

#Preview {
    CockPostView(detailPost: PostElement(uid: "", title: "定食", isPrivate: false, createAt: Date(), likeCount: 10, likedUser: [], comment: []))
}
