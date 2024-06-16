import SwiftUI

struct AdvertisementView: View {
    var body: some View {
        ZStack {
            // 背景
            Image("foodImage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                Text("アマギフキャンペーン")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .padding(.top, 20)

                Text("みんなのごはんをシェアして、豪華賞品をゲットしよう！日々のごはんの写真を投稿するだけで、1000円分のアマギフが手に入るチャンス。参加は簡単、あなたのごはんをシェアするだけ！")
                    .font(.body)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(10)
                    .padding()

                VStack(alignment: .leading, spacing: 10) {
                    Text("条件:")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("1. 2024年7月1日までにごはんを10回投稿")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    Text("2. 1日は3回まで")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    Text("3. アンケートに答えた方")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    Text("4. 当選者は1名")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color.green.opacity(0.9))
                .cornerRadius(10)

                Text("キャンペーン終了時点までの投稿数をカウントします。キャンペーンは予告なく終了する場合がございます。また、ごはん以外の投稿はカウントされません。")
                    .foregroundColor(.black)
                    .padding()

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    AdvertisementView()
}
