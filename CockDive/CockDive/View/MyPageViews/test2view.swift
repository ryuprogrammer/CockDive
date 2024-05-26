import SwiftUI

struct Test2View: View {
    @State private var selectedIndex: Int = 0  // 選択されたタブのインデックスを管理する状態変数
    @State private var offset: CGFloat = 0  // オフセット値を管理する状態変数
    @State private var tabOffset: CGFloat = 0
    let tabTitles = ["Tab 1", "Tab 2", "Tab 3"]  // タブのタイトルを格納した配列

    var body: some View {
        GeometryReader { geo in  // 親ビューのジオメトリ情報を取得
            VStack {
                HStack {
                    ForEach(Array(tabTitles.enumerated()), id: \.offset) { index, title in  // タブタイトルごとにビューを作成
                        VStack {
                            Text(title)
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
                    .frame(width: geo.size.width / CGFloat(tabTitles.count), height: 2)
                    .offset(x: tabOffset)
                    .animation(.easeInOut, value: tabOffset)

                TabView(selection: $selectedIndex) {
                    ForEach(Array(tabTitles.enumerated()), id: \.offset) { index, title in
                        VStack {
                            Text(title)
                                .frame(maxWidth: .infinity)
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .onAppear {
                tabOffset -= geo.size.width / CGFloat(tabTitles.count)
            }
            .onChange(of: selectedIndex) { index in
                if index == 0 {
                    tabOffset =  -(geo.size.width / CGFloat(tabTitles.count))
                } else if index == 1 {
                    tabOffset = 0
                } else if index == 2 {
                    tabOffset = geo.size.width / CGFloat(tabTitles.count)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Test2View()
    }
}
