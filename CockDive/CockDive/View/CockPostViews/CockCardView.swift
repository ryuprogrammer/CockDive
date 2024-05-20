import SwiftUI

struct CockCardView: View {
    let postData: PostElement
    let isFollow: Bool
    let isLike: Bool
    // 画面表示用のPostData
    @State private var showPostData: PostElement = PostElement(uid: "", title: "", isPrivate: true, createAt: Date(), likeCount: 0, likedUser: [], comment: [])
    // 画面表示用のフォロープロパティ
    @State private var showIsFollow: Bool = false
    // 画面表示用のライクプロパティ
    @State private var showIsLike: Bool = false
    
    let maxTextCount = 20
    @State private var cockCardVM = CockCardViewModel()
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
                let iconImageURL = URL(string: postData.postUserIconImageURL ?? "")
                
                AsyncImage(url: iconImageURL) { image in
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
                
                Text("\(showPostData.postUserNickName ?? "ニックネーム")さん")
                
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
                
                if !showIsFollow {
                    StrokeButton(text: "フォロー", size: .small) {
                        showIsFollow = true
                    }
                } else {
                    StrokeButton(text: "フォロー中", size: .small) {
                        showIsFollow = false
                    }
                }
            }
            
            let imageURL = URL(string: showPostData.postImageURL ?? "")
            
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
                Text(showPostData.title)
                    .font(.title)
                
                Spacer()
                
                VStack(spacing: 1) {
                    Image(systemName: "message")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundStyle(Color.black)
                        .onTapGesture {
                            path.append(postData)
                        }
                    
                    Text(String(showPostData.comment.count))
                        .font(.footnote)
                }
                
                VStack(spacing: 1) {
                    Image(systemName: showIsLike ? "heart.fill" : "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundStyle(Color.pink)
                        .onTapGesture {
                            showIsLike.toggle()
                        }
                    
                    Text(String(showPostData.likeCount))
                        .font(.footnote)
                }
            }
            
            if let memo = showPostData.memo {
                DynamicHeightCommentView(message: memo, maxTextCount: maxTextCount)
            }
            
            Divider()
        }
        .onAppear {
            showIsFollow = isFollow
            showIsLike = isLike
        }
        .onChange(of: showIsFollow) { _ in
            Task {
                await cockCardVM.followUser(friendUid: postData.uid)
            }
        }
        .onChange(of: showIsLike) { _ in
            if showIsLike {
                showPostData.likeCount += 1
            } else {
                showPostData.likeCount -= 1
            }
            Task {
                await cockCardVM.likePost(post: postData)
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
