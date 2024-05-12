import SwiftUI

@main
struct CockDiveApp: App {
    let persistenceController = PersistenceController.shared

    @State private var viewSelection: ViewType = .cockCard
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $viewSelection) {
                CockCardsView()
                    .tabItem {
                        Image(systemName: "fork.knife")
                        Text("ご飯")
                    }
                    .tag(ViewType.cockCard)
                
                MyPageView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("ホーム")
                    }.tag(ViewType.home)
            }
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

enum ViewType {
    case cockCard
    case home
}
