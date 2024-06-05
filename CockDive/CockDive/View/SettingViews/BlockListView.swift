import SwiftUI

struct BlockListView: View {
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockCardNavigationPath]
    @ObservedObject var blockListVM = BlockListViewModel()
    @State var showBlockUser: [UserElement] = []
    @State var lastUserData: UserElement? = nil

    var body: some View {
        ScrollViewReader { proxy in
            if showBlockUser.isEmpty {
                Text("ブロックしているユーザーはいません")
            } else {
                List {
                    ForEach(showBlockUser, id: \.id) { userData in
                        Text("\(userData.nickName)")
                            .id(userData.id)
                            .onAppear {
                                if let id = userData.id,
                                   let lastUser = showBlockUser.last,
                                   let lastId = lastUser.id {
                                    if id == lastId {
                                        Task {
                                            await blockListVM.fetchBlockUserByStatus()
                                        }
                                    }
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    if let index = showBlockUser.firstIndex(where: { $0.id == userData.id }) {
                                        guard let uid = userData.id else { return }
                                        Task {
                                            await blockListVM.removeBlockUser(uid: uid)
                                        }
                                        showBlockUser.remove(at: index)
                                    }
                                } label: {
                                    Text("ブロック解除")
                                }
                            }
                    }
                    .onChange(of: showBlockUser) { _ in
                        if let lastUserData = lastUserData {
                            proxy.scrollTo(lastUserData.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    Task {
                        if blockListVM.loadStatus == .initial {
                            await blockListVM.fetchBlockUserByStatus()
                        }
                    }
                }
                .refreshable {
                    blockListVM.loadStatus = .initial
                    showBlockUser.removeAll()
                    blockListVM.newBlockUserData.removeAll()
                    Task {
                        await blockListVM.fetchBlockUserByStatus()
                    }
                }
                .onChange(of: blockListVM.newBlockUserData) { newUser in
                    // データを画面に描画
                    showBlockUser.append(contentsOf: newUser)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("ブロックリスト")
        .toolbarColorScheme(.dark)
        .toolbarBackground(Color.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        BlockListView(
            path: .constant([]),
            showBlockUser: [
                UserElement(id: "1", nickName: "ユーザー1", introduction: "自己紹介1", iconImage: nil, iconURL: nil),
                UserElement(id: "2", nickName: "ユーザー2", introduction: "自己紹介2", iconImage: nil, iconURL: nil)
            ]
        )
    }
}
