import SwiftUI

struct MainView: View {
    @State private var viewSelection: ViewType = .cockCard
    var body: some View {
        TabView {
            
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
