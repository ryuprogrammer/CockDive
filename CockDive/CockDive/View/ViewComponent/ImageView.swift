import SwiftUI

enum ImageType {
    case icon
    case post
}

/*
data、URLからUIImageを表示
 firestoreはドキュメントの最大サイズ: 1 MiB（1,048,576 バイト）
 だいたい写真が148,388 byteくらい（0.5倍）

 - 保存するとき
     - 1000000byte→1MiBまではData型で保存
     - それより大きい時はData型はnilにする
     - URLは常に保存
 - 取得するとき
     - Data型がnilなら、URLで非同期取得
         - AsyncImage
 */

struct ImageView: View {
    var data: Data?
    var urlString: String?
    var imageType: ImageType

    var body: some View {
        if let data = data, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let urlString = urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        VStack {
            switch imageType {
            case .icon:
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundStyle(Color.mainColor)
            case .post:
                Image(systemName: "carrot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(50)
                    .background(Color.mainColor)
                    .foregroundStyle(Color.white)
            }
        }
    }
}

#Preview {
    VStack {
        ImageView(imageType: .icon)
            .frame(width: 100, height: 100)
            .foregroundStyle(Color.mainColor)
        ImageView(imageType: .post)
            .frame(width: 300, height: 300)
            .foregroundStyle(Color.white)
    }
}
