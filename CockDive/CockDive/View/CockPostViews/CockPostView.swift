import SwiftUI

struct CockPostView: View {
    // 投稿追加画面の表示有無
    @State private var isShowSheet: Bool = false
    @ObservedObject var cockPostVM = CockPostViewModel()
    let cockCardVM = CockCardViewModel()
    // postDetail用のpostデータ
    @State var detailPost: PostElement = PostElement(uid: "B4uotKO8WiPsylwU5LYSCYBUPjk2", title: "sss", isPrivate: false, createAt: Date(), likeCount: 10, likedUser: [], comment: [])
    
    var body: some View {
        NavigationStack {
            ZStack {
                List(cockPostVM.postData, id: \.id) { postData in
                    VStack {
                        CockCardView(postData: postData)
                        // メッセージ画面への遷移ボタン
                        NavigationLink(destination: PostDetailView(postData: postData)) {
                            Text("コメント")
                            Text("\(postData.comment.count)件")
                        }
                    }
                }
                .padding()
                
                Button(action: {
                    isShowSheet = true
                }, label: {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: 65, height: 65)
                        .foregroundStyle(Color.white)
                        .background(Color("main"))
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
            .toolbarBackground(Color("main"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("みんなのご飯")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $isShowSheet) {
            AddPostView()
        }
        .onAppear {
            Task {
                await cockPostVM.fetchPost()
            }
        }
    }
}

#Preview {
    CockPostView(detailPost: PostElement(uid: "", title: "定食", isPrivate: false, createAt: Date(), likeCount: 10, likedUser: [], comment: []))
}
