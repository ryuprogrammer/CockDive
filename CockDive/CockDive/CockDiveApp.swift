import SwiftUI

@main
struct CockDiveApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .white
        
        // タブ選択時のテキスト設定
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(.mainColor.opacity(0.8)), .font: UIFont.systemFont(ofSize: 10, weight: .bold)]
        // タブ選択時のアイコン設定
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(.mainColor.opacity(0.8))
        
        // タブ非選択時のテキスト設定
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(.black.opacity(0.5)), .font: UIFont.systemFont(ofSize: 10, weight: .medium)]
        // タブ非選択時のアイコン設定
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(.black.opacity(0.5))
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        UITabBar.appearance().barTintColor = .green
    }
    
    var body: some Scene {
        WindowGroup {
            FirstView()
            //                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
