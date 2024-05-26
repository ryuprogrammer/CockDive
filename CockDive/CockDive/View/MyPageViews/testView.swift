import SwiftUI
import Combine

struct TestView: View {
    @State private var activeTab: DummyTab = .home
    @ObservedObject var offsetObserver = PageOffsetObserver()

    var body: some View {
        VStack(spacing: 15) {
            ZStack(alignment: .bottomLeading) {
                Tabbar(activeTab: $activeTab, offsetObserver: offsetObserver)
            }

            GeometryReader { geo in
                let width = geo.size.width
                let tabCount = CGFloat(DummyTab.allCases.count)
                let capsuleWidth = width / tabCount
                let progress = offsetObserver.offset / geo.size.width

                VStack {
                    Text("progress: \(progress)")

                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.pink)
                        .frame(width: capsuleWidth - 20, height: 30)
                        .offset(x: progress + capsuleWidth + 10)
                        .animation(.easeInOut, value: offsetObserver.offset)
                }
            }
            .frame(height: 40)

            TabView(selection: $activeTab) {
                ForEach(DummyTab.allCases, id: \.self) { tab in
                    tab.view
                        .tag(tab)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(key: ViewOffsetKey.self, value: geo.frame(in: .global).minX)
                            }
                        )
                        .onAppear {
                            offsetObserver.updateBounds(for: tab)
                        }
                        .onPreferenceChange(ViewOffsetKey.self) { value in
                            offsetObserver.offset = value
                        }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
        }
        .environmentObject(offsetObserver)
    }
}

#Preview {
    TestView()
}

enum DummyTab: String, CaseIterable {
    case home = "Home"
    case chats = "Chats"
    case calls = "Calls"
    case settings = "Settings"

    var view: some View {
        switch self {
        case .home:
            return AnyView(Color.red)
        case .chats:
            return AnyView(Color.blue)
        case .calls:
            return AnyView(Color.green)
        case .settings:
            return AnyView(Color.yellow)
        }
    }
}

class PageOffsetObserver: ObservableObject {
    @Published var offset: CGFloat = 0
    var collectionViewBounds: CGRect = .zero

    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: NSNotification.Name("PageOffsetChanged"))
            .compactMap { $0.object as? CGFloat }
            .assign(to: \.offset, on: self)
    }

    deinit {
        cancellable?.cancel()
    }

    func updateBounds(for tab: DummyTab) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let viewController = window.rootViewController,
               let tabBarController = viewController.children.first as? UITabBarController,
               let navController = tabBarController.selectedViewController as? UINavigationController,
               let rootViewController = navController.viewControllers.first {

                self.collectionViewBounds = rootViewController.view.bounds
            }
        }
    }
}

extension View {
    func onPageOffsetChange(perform action: @escaping (CGFloat) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PageOffsetChanged"))) { notification in
            if let offset = notification.object as? CGFloat {
                action(offset)
            }
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct Tabbar: View {
    @Binding var activeTab: DummyTab
    @ObservedObject var offsetObserver: PageOffsetObserver

    var body: some View {
        HStack {
            ForEach(DummyTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation {
                        activeTab = tab
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(activeTab == tab ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.clear)
                }
            }
        }
        .background(Color.white)
    }
}
