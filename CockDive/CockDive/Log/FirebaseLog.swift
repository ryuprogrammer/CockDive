//
//  FirebaseLog.swift
//  CockDive
//
//  Created by 駒橋龍 on 2024/09/30.
//

import Foundation
import FirebaseAnalytics

// MARK: - Screen enum
enum Screen: String, Codable {

    // MARK: - スタート画面
    /// サインイン画面
    case signInView = "サインイン画面"
    /// 名前登録画面
    case nameRegistrationView = "名前登録画面"
    /// アイコン写真登録画面
    case iconRegistrationView = "アイコン写真登録画面"

    // MARK: - 投稿画面
    /// 投稿画面
    case cockPostView = "投稿画面"
    /// 投稿作成画面
    case addPostView = "投稿作成画面"
    /// ユーザー詳細画面
    case userDetailView = "ユーザー詳細画面"
    /// 投稿詳細画面
    case postDetailView = "投稿詳細画面"
    
    // MARK: - マイページ画面
    /// マイページ画面
    case myPageView = "マイページ画面"
    /// 自分の投稿画面
    case myPostView = "自分の投稿画面"
    /// いいねした投稿画面
    case myLikeView = "いいねした投稿画面"
    
    // MARK: - 設定画面
    /// 設定画面
    case settingView = "設定画面"
    /// プロフ編集画面
    case myProfileEditView = "プロフ編集画面"
    /// テーマカラー編集画面
    case mainColorEditView = "テーマカラー編集画面"
    /// お知らせ画面
    /// プライバシーポリシー画面
    /// 利用規約画面
    /// レビューを書く画面
    /// アプリをシェア画面
    /// 運営へのお問い合わせ画面
    /// ログアウト
    case logoutView = "ログアウト画面"
    /// アカウント削除
    case deleteAccountView = "アカウント削除画面"
}

// MARK: - LogButton enum
enum LogButton: String, Codable {
    /// 投稿画面遷移ボタン
    case showAddPostViewButton = "投稿画面遷移ボタン"
    /// 新規投稿ボタン
    case addPostButton = "新規投稿ボタン"
    /// 編集投稿ボタン
    case editPostButton = "編集投稿ボタン"
    /// いいねボタン
    case likeButton = "いいねボタン"
    /// アルバムから選ぶボタン
    case albumButton = "アルバムから選ぶボタン"
    /// 写真を撮るボタン
    case photoButton = "写真を撮るボタン"
    /// 料理名入力ボタン
    case titleButton = "料理名入力ボタン"
    /// メモ入力ボタン
    case memoButton = "メモ入力ボタン"
}

class FirebaseLog {
    // シングルトンインスタンス
    static let shared = FirebaseLog()

    // プライベートイニシャライザ（外部からのインスタンス化を防ぐ）
    private init() {}

    // MARK: - 画面表示ログを送信
    func logScreenView(_ screen: Screen) {
        print("logScreenView")
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screen.rawValue,
            AnalyticsParameterScreenClass: screen.rawValue
        ])
    }
    
    // MARK: - ボタンタップログを送信
    func logButtonTap(_ button: LogButton) {
        print("logButtonTap")
        Analytics.logEvent("button_tap", parameters: [
            "button_name": button.rawValue
        ])
    }
}
