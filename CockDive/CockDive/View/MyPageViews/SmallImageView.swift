import SwiftUI

struct SmallImageView: View {
    let day: Int
    @Binding var posts: [MyPostModel]
    @State private var showModal = false

    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    var screenWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.width
        }
        return 400
    }

    var body: some View {
        ZStack {
            if let data = posts.last?.image,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: screenWidth / 7 - 5,
                        height: (window?.screen.bounds.height ?? 800) / 10
                    )
            } else {
                Image(systemName: "carrot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.white)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.mainColor.opacity(0.3))
                            .frame(
                                width: screenWidth / 7 - 5,
                                height: (window?.screen.bounds.height ?? 800) / 10
                            )
                    }
                    .frame(
                        width: screenWidth / 13 - 5,
                        height: screenWidth / 10
                    )
            }

            VStack {
                if posts.count >= 2  {
                    HStack {
                        Spacer()
                        Text("\(posts.count)")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .frame(
                                width: (window?.screen.bounds.width ?? 400) / 20
                            )
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .frame(
                        width: (window?.screen.bounds.width ?? 400) / 7 - 5
                    )
                }

                Spacer()

                if posts.isEmpty {
                    Text("\(day)日")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .frame(
                            width: (window?.screen.bounds.width ?? 400) / 7 - 5
                        )
                } else {
                    Text("\(day)日")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .frame(
                            width: (window?.screen.bounds.width ?? 400) / 7 - 5
                        )
                        .background(
                            Color.black.blur(radius: 10)
                        )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(
            width: (window?.screen.bounds.width ?? 400) - 50,
            height: (window?.screen.bounds.height ?? 800) / 10
        )
        .onTapGesture {
            showModal.toggle()
        }
        .sheet(isPresented: $showModal) {
            HalfModalView(posts: posts)
        }
    }
}

struct HalfModalView: View {
    let posts: [MyPostModel]

    var date: Date {
        return posts.first?.createAt ?? Date()
    }

    // 画面サイズ取得
    var cardWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return (screen.bounds.width) * 2 / 3
        }
        return 400
    }

    // 画面サイズ取得
    var modalHeight: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.width - 10
        }
        return 400
    }

    var body: some View {
        VStack {
            HStack {
                Text(date.dateStringDate())
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 5)
                    .padding(.leading)

                Spacer()
            }

            if posts.isEmpty {
                Spacer()
                Text("この日の記録はありません")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 5)
                    .padding(.leading)
                Spacer()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(posts, id: \.id) { post in
                            if let data = post.image,
                               let uiImage = UIImage(data: data) {
                                VStack(alignment: .leading) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: cardWidth, height: cardWidth)
                                        .clipShape(Rectangle())

                                    Text(post.wrappedTitle)
                                        .fontWeight(.bold)
                                        .padding(.leading)

                                    ScrollView {
                                        Text(post.wrappedMemo)
                                            .padding(.leading)
                                    }

                                    Spacer()
                                }
                                .frame(width: cardWidth)
                            }
                        }
                    }
                }
            }
        }
        .frame(height: modalHeight)
        .presentationDetents([
            .medium
        ])
    }
}

#Preview {
    SmallImageView(day: 12, posts: .constant([]))
}
