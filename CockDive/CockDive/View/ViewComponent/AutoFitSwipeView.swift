import SwiftUI

struct AutoFitSwipeView<Content: View>: View {
    // 表示するコンテンツ
    let content: () -> Content

    // オフセットと現在のインデックス用の変数
    @State private var offset: CGFloat = 0
    @State private var currentIndex: Int = 0

    // 画面サイズ取得
    var screenWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.width
        }
        return 400
    }

    var body: some View {
        GeometryReader { geometry in
            // スクロール位置を制御するためのScrollViewReader
            ScrollViewReader { proxy in
                // 水平方向のScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    // コンテンツを横に並べるためのHStack
                    HStack(spacing: 0) {
                        // 呼び出し元から渡されたコンテンツを表示
                        content()
                            .frame(width: screenWidth, height: geometry.size.height)
                    }
                }
                // スクロール位置をオフセットする
                .content.offset(x: -CGFloat(currentIndex) * screenWidth + offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // スワイプ中のオフセットを更新
                            self.offset = value.translation.width
                        }
                        .onEnded { value in
                            // スワイプが終わったときに、画面幅の半分以上スワイプされたら次のページに移動
                            withAnimation {
                                if value.translation.width < -screenWidth / 2 {
                                    currentIndex = 1
                                } else if value.translation.width > screenWidth / 2 {
                                    currentIndex = 0
                                }
                                // オフセットをリセット
                                offset = 0
                            }
                        }
                )
                // ビューが表示されたときにオフセットをリセット
                .onAppear {
                    offset = 0
                }
            }
        }
        // ビューを中央に配置するためのオフセットを計算
        .offset(x: (UIScreen.main.bounds.width - screenWidth) / 2)
    }
}

#Preview {
    AutoFitSwipeView() {
        Group {
            Text("１つ目の画面")
                .frame(width: 350, height: 500)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()

            Text("2つ目の画面")
                .frame(width: 350, height: 500)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
        }
    }
}
