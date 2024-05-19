import SwiftUI

struct CockCardView: View {
    let postData: PostElement
    // 画面表示用のPostData
    @State private var showPostData: PostElement = PostElement(uid: "", title: "", isPrivate: true, createAt: Date(), likeCount: 0, likedUser: [], comment: [])
    
    let maxTextCount = 20
    @State private var cockCardVM = CockCardViewModel()
    @State private var isLike: Bool = false
    @State private var isLineLimit: Bool = false
    var screenWidth: CGFloat {
        #if DEBUG
        return UIScreen.main.bounds.width
        #else
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first?.screen.bounds.width ?? 50
        #endif
    }
    
    @Binding var path: [PostElement]

    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: cockCardVM.iconImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth / 10, height: screenWidth / 10)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.gray)
                        .frame(width: screenWidth / 10, height: screenWidth / 10)
                }
                
                Text("\(String(describing: cockCardVM.nickName))さん")
                
                Menu {
                    Button(action: {
                        Task {
                            /// ブロックするアクション
                            await cockCardVM.blockUser(friendUid: postData.uid)
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "nosign")
                            Spacer()
                            Text("ブロック")
                        }
                    })
                    
                    Button(action: {
                        /// 通報するアクション
                        cockCardVM.reportUser(friendUid: postData.uid)
                    }, label: {
                        HStack {
                            Image(systemName: "exclamationmark.bubble")
                            Spacer()
                            Text("通報")
                        }
                    })
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.black)
                        .frame(width: 30, height: 30)
                }
                
                Spacer()
                
                if !cockCardVM.isFollow {
                    StrokeButton(text: "フォロー", size: .small) {
                        Task {
                            /// フォロー
                            await cockCardVM.followUser(friendUid: postData.uid)
                        }
                    }
                }
            }
            
            let imageURL = URL(string: postData.postImageURL ?? "")
            
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } placeholder: {
                ProgressView()
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            HStack(alignment: .top, spacing: 20) {
                Text(postData.title)
                    .font(.title)
                
                Spacer()
                
                VStack(spacing: 1) {
                    Image(systemName: "message")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundStyle(Color.pink)
                        .onTapGesture {
                            path.append(postData)
                        }
                    
                    Text(String(postData.likeCount))
                        .font(.footnote)
                }
                
                VStack(spacing: 1) {
                    Image(systemName: postData.likedUser.contains("") ? "heart" : "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundStyle(Color.pink)
                        .onTapGesture {
                            Task {
                                await cockCardVM.likePost(post: postData)
                            }
                        }
                    
                    Text(String(postData.likeCount))
                        .font(.footnote)
                }
            }
            
            if let memo = postData.memo {
                DynamicHeightCommentView(message: memo, maxTextCount: maxTextCount)
            }
            
            Divider()
        }
        .onAppear {
            Task {
                await cockCardVM.initData(friendUid: postData.uid)
                await cockCardVM.isFollowFriend(friendUid: postData.uid)
            }
        }
    }
}

//#Preview {
//    struct PreviewView: View {
//        
//        let postData: PostElement = PostElement(uid: "dummy_uid", postImageURL: "https://example.com/image.jpg", title: "定食", memo: "ここに説明文を挿入", isPrivate: false, createAt: Date(), likeCount: 555, likedUser: [], comment: [])
//        
//        var body: some View {
//            CockCardView(postData: postData)
//        }
//    }
//    return PreviewView()
//}
