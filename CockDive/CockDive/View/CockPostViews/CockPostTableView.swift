import UIKit
import SwiftUI

// SwiftUIのUIViewControllerRepresentableプロトコルを使ってUIViewControllerをSwiftUIで使用可能にする
struct CockPostTableView: UIViewControllerRepresentable {
    var cockPostVM: CockPostViewModel  // ビューモデルのインスタンス
    @Binding var userFriendData: UserFriendElement?  // バインディング変数としてユーザーフレンドデータを保持
    
    // SwiftUIのUIViewControllerRepresentableプロトコルのメソッド
    func makeUIViewController(context: Context) -> CockPostViewController {
        // UIViewControllerのインスタンスを作成
        let viewController = CockPostViewController()
        // ビューモデルを設定
        viewController.cockPostVM = cockPostVM
        // ユーザーフレンドデータを設定
        viewController.userFriendData = userFriendData
        // デリゲートを設定
        viewController.delegate = context.coordinator
        // 作成したビューコントローラーを返す
        return viewController
    }
    
    // SwiftUIのUIViewControllerRepresentableプロトコルのメソッド
    func updateUIViewController(_ uiViewController: CockPostViewController, context: Context) {
        // ユーザーフレンドデータを更新
        uiViewController.userFriendData = userFriendData
        // テーブルビューをリロード
        uiViewController.tableView.reloadData()
    }
    
    // コーディネーターを作成するためのメソッド
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // コーディネータークラス
    class Coordinator: NSObject, CockPostViewControllerDelegate {
        var parent: CockPostTableView
        
        init(_ parent: CockPostTableView) {
            self.parent = parent
        }
        
        // 投稿が選択されたときの処理
        func didSelectPost(_ postData: PostElement) {
//            parent.cockPostVM.selectedPost = postData
        }
    }
}
