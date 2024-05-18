import SwiftUI

struct CockCardView: View {
    let maxTextCount = 20
    let postData: PostElement
    @State private var cockCardVM = CockCardViewModel()
    @State private var isLike: Bool = false
    @State private var isFollow: Bool = false
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
    @Binding var path: [CockPostViewPath]
    
    let blockAction: () -> Void
    let reportAction: () -> Void
    let followAction: () -> Void
    let likeAction: () -> Void
    let navigateAction: () -> Void

    init(postData: PostElement, path: Binding<[CockPostViewPath]>, blockAction: @escaping () -> Void, reportAction: @escaping () -> Void, followAction: @escaping () -> Void, likeAction: @escaping () -> Void, navigateAction: @escaping () -> Void) {
        self.postData = postData
        self._path = path
        self.blockAction = blockAction
        self.reportAction = reportAction
        self.followAction = followAction
        self.likeAction = likeAction
        self.navigateAction = navigateAction
    }

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
                        blockAction()
                    }, label: {
                        HStack {
                            Image(systemName: "nosign")
                            Spacer()
                            Text("ブロック")
                        }
                    })
                    
                    Button(action: {
                        reportAction()
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
                StrokeButton(text: "フォロー", size: .small) {
                    followAction()
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
                        .frame(width: 25)
                        .onTapGesture {
                            navigateAction()
                            path.append(.postDetailView)
                        }
                    
                    Text(String(postData.comment.count))
                        .font(.footnote)
                }
                
                VStack(spacing: 1) {
                    Image(systemName: isLike ? "heart" : "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25)
                        .foregroundStyle(Color.pink)
                        .onTapGesture {
                            withAnimation {
                                isLike.toggle()
                            }
                            likeAction()
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
            var isFollow = false
            Task {
                await cockCardVM.initData(friendUid: postData.uid)
                await cockCardVM.isFollowFriend(friendUid: postData.uid)
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State private var path: [CockPostViewPath] = []
        
        let postData: PostElement = PostElement(uid: "dummy_uid", postImageURL: "https://example.com/image.jpg", title: "定食", memo: "ここに説明文を挿入", isPrivate: false, createAt: Date(), likeCount: 555, likedUser: [], comment: [])
        
        var body: some View {
            CockCardView(postData: postData, path: $path) {
                
            } reportAction: {
                
            } followAction: {
                
            } likeAction: {
                
            } navigateAction: {
                
            }
        }
    }
    return PreviewView()
}
