import SwiftUI

struct Test2View: View {
    @State private var selectedIndex: Int = 0  // 選択されたタブのインデックスを管理する状態変数
    @State private var tabOffset: CGFloat = 0

    let tabs: [(title: String, view: AnyView)]  // タイトルとビューのタプル配列

    var body: some View {
        GeometryReader { geo in  // 親ビューのジオメトリ情報を取得
            VStack {
                HStack {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in  // タブタイトルごとにビューを作成
                        VStack {
                            Text(tab.title)
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    withAnimation {
                                        selectedIndex = index  // タブを選択した際にインデックスを更新
                                    }
                                }
                        }
                    }
                }

                // 選択中のタブを示すための下線
                Rectangle()
                    .frame(width: geo.size.width / CGFloat(tabs.count), height: 2)
                    .offset(x: tabOffset)
                    .animation(.easeInOut, value: tabOffset)

                TabView(selection: $selectedIndex) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        tab.view
                            .tag(index)
                            .frame(maxWidth: .infinity)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .onAppear {
                tabOffset -= geo.size.width / CGFloat(tabs.count)
            }
            .onChange(of: selectedIndex) { index in
                if index == 0 {
                    tabOffset =  -(geo.size.width / CGFloat(tabs.count))
                } else if index == 1 {
                    tabOffset = 0
                } else if index == 2 {
                    tabOffset = geo.size.width / CGFloat(tabs.count)
                }
            }
        }
    }
}

struct RyuView: View {
    var body: some View {
        Test2View(
            tabs: [
                (title: "カレンダー", view: AnyView(Text("カレンダー"))),
                (title: "投稿", view: AnyView(Text("投稿"))),
                (title: "いいね", view: AnyView(Text("いいね")))
            ]
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RyuView()
    }
}
