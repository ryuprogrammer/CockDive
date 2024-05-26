import SwiftUI

struct SwipeableTabView: View {
    let tabs: [(title: String, view: AnyView)]

    @State private var selectedIndex: Int = 0
    @State private var tabOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        if index == selectedIndex {
                            Text(tab.title)
                                .frame(maxWidth: .infinity)
                                .fontWeight(.bold)
                                .onTapGesture {
                                    withAnimation {
                                        selectedIndex = index
                                    }
                                }
                        } else {
                            Text(tab.title)
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    withAnimation {
                                        selectedIndex = index
                                    }
                                }
                        }
                    }
                }

                Divider()
                    .overlay {
                        // 選択中のタブを示すための下線
                        Rectangle()
                            .frame(width: geo.size.width / CGFloat(tabs.count), height: 2)
                            .offset(x: -(geo.size.width / CGFloat(tabs.count)) + tabOffset)
                            .animation(.easeInOut, value: tabOffset)
                    }

                TabView(selection: $selectedIndex) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        tab.view
                            .tag(index)
                            .frame(maxWidth: .infinity)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .onChange(of: selectedIndex) { index in
                withAnimation {
                    tabOffset = (geo.size.width / CGFloat(tabs.count)) * CGFloat(index)
                }
            }
        }
    }
}

#Preview {
    SwipeableTabView(
        tabs: [
            (title: "カレンダー", view: AnyView(Text("カレンダー"))),
            (title: "投稿", view: AnyView(Text("投稿"))),
            (title: "いいね", view: AnyView(Text("いいね")))
        ]
    )
}

