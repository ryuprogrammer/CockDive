import SwiftUI

struct MainView: View {
    @State private var viewSelection: ViewType = .cockCard
    var body: some View {
        TabView(selection: $viewSelection) {
            CockCardsView()
                .tabItem {
                    Image(systemName: "fork.knife")
                }
                .tag(ViewType.cockCard)
            Text("Tab Content 2").tabItem { /*@START_MENU_TOKEN@*/Text("Tab Label 2")/*@END_MENU_TOKEN@*/ }.tag(2)
        }
    }
}

enum ViewType {
    case cockCard
    case home
}

#Preview {
    MainView()
}
