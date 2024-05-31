import SwiftUI

struct SmallImageView: View {
    let day: Int
    let posts: [MyPostModel]
    let image: Image = Image("cockImage")

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
    }
}

#Preview {
    SmallImageView(day: 12, posts: [])
}

