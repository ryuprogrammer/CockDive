import UIKit
import SwiftUI

// デリゲートプロトコル
protocol CockPostViewControllerDelegate: AnyObject {
    func didSelectPost(_ postData: PostElement)
}

// カスタムビューコントローラー
class CockPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CockPostViewControllerDelegate {
    
    var tableView: UITableView!
    var postsData: [PostElement] = []  // 投稿データの配列
    var cockPostVM: CockPostViewModel!  // ビューモデル
    var userFriendData: UserFriendElement?  // ユーザーフレンドデータ
    weak var delegate: CockPostViewControllerDelegate?  // デリゲート
    
    private var isFetchingMoreData = false  // データを追加でフェッチ中かどうかを示すフラグ
    
    // ビューがロードされたときの処理
    override func viewDidLoad() {
        super.viewDidLoad()
        // テーブルビューをセットアップ
        setupTableView()
        // データをフェッチ
        fetchData()
    }
    
    // テーブルビューをセットアップするメソッド
    private func setupTableView() {
        // テーブルビューのインスタンスを作成
        tableView = UITableView(frame: view.bounds, style: .plain)
        // デリゲートを設定
        tableView.delegate = self
        // データソースを設定
        tableView.dataSource = self
        // カスタムセルを登録
        tableView.register(CockCardTableViewCell.self, forCellReuseIdentifier: "CockCardTableViewCell")
        // セパレーターを非表示
        tableView.separatorStyle = .none
        // テーブルビューをビューに追加
        view.addSubview(tableView)
    }
    
    // データをフェッチするメソッド
    private func fetchData() {
        isFetchingMoreData = true
        Task {
            // ユーザーフレンドデータをフェッチ
            userFriendData = await cockPostVM.fetchUserFriendElement()
            // 投稿データをフェッチ
            await cockPostVM.fetchPosts()
            // 投稿データをセット
            postsData = cockPostVM.postsData
            // テーブルビューをリロード
            tableView.reloadData()
            isFetchingMoreData = false
        }
    }
    
    // 追加データをフェッチするメソッド
    private func fetchMoreData() {
        guard !isFetchingMoreData else { return }  // フェッチ中であればリターン
        isFetchingMoreData = true
        Task {
            // 新しい投稿データをフェッチ
            await cockPostVM.fetchMorePosts()
            // 新しい投稿データを追加
            postsData.append(contentsOf: cockPostVM.postsData)
            // テーブルビューをリロード
            tableView.reloadData()
            isFetchingMoreData = false
        }
    }
    
    // UITableViewDataSourceプロトコルのメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セクション内の行数を返す
        return postsData.count
    }
    
    // UITableViewDataSourceプロトコルのメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CockCardTableViewCell", for: indexPath) as! CockCardTableViewCell
        let postData = postsData[indexPath.row]
        // セルを設定
        cell.configure(with: postData, friendData: userFriendData)
        // デリゲートを設定
        cell.delegate = self
        return cell
    }
    
    // CockPostViewControllerDelegateプロトコルのメソッド
    func didSelectPost(_ postData: PostElement) {
        // 詳細ビューを作成
        let detailView = PostDetailViewWrapper(postData: postData)
        // ホスティングコントローラーを作成
        let hostingController = UIHostingController(rootView: detailView)
        // ナビゲーションコントローラーで詳細ビューに遷移
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    // UIScrollViewDelegateプロトコルのメソッド
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // テーブルビューのコンテンツ高さ
        let contentHeight = scrollView.contentSize.height
        // テーブルビューの高さ
        let tableViewHeight = scrollView.frame.size.height
        // 現在のスクロール位置
        let offsetY = scrollView.contentOffset.y
        
        // テーブルビューが一番下までスクロールしたかどうかを検知
        if offsetY + tableViewHeight >= contentHeight {
            // 一番下までスクロールした場合の処理
            print("テーブルビューが一番下までスクロールされました")
            // 追加データをフェッチ
            fetchMoreData()
        }
    }
}
