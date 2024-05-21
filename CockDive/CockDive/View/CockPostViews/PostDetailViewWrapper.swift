import SwiftUI

// SwiftUIのPostDetailViewを表示するためのビューラッパー
struct PostDetailViewWrapper: UIViewControllerRepresentable {
    let postData: PostElement
    
    func makeUIViewController(context: Context) -> UIViewController {
        // ホスティングコントローラーを作成
        let hostingController = UIHostingController(rootView: PostDetailView(postData: postData))
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
