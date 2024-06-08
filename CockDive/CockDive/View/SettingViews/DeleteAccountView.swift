import SwiftUI

enum ActiveAlert {
    case confirmDeletion
    case error(String)
}

struct DeleteAccountView: View {
    @State private var signInWithAppleObject = SignInWithAppleObject()
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockCardNavigationPath]
    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert?
    @State private var isLoading = false // ローディング状態を追加
    @ObservedObject var authenticationManager = AuthenticationManager()

    let deletionWarningMessage = """
    アカウント削除について

    アカウントの削除を行うと、以下の情報が全て失われますのでご注意ください。

    ✅ これまでの投稿やコメント
    ✅ 保存しているお気に入りのリスト
    ✅ 他のユーザーとのメッセージ履歴

    一度削除されたデータは復元できません。

    本当にアカウントを削除しますか？

    もし、アカウントの利用についてお困りのことがございましたら、サポートチームまでご連絡ください。アカウント削除以外の方法で解決できる可能性があります。

    サポートチーム連絡先：「設定」→「お問い合わせ」

    アカウントを削除せずに続ける場合、以下の「キャンセル」ボタンをクリックしてください。

    それでもアカウントを削除する場合は、「削除する」ボタンをクリックしてください。
    """

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(deletionWarningMessage)

                Spacer()

                Button(action: {
                    activeAlert = .confirmDeletion
                    showAlert = true
                }) {
                    if isLoading { // ローディング状態の場合はローディングインジケータを表示
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.white)
                    } else {
                        Text("アカウント削除")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading) // ローディング中はボタンを無効にする
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .confirmDeletion:
                return Alert(
                    title: Text("アカウント削除確認"),
                    message: Text("本当に削除しますか？"),
                    primaryButton: .destructive(Text("削除する")) {
                        // 削除ボタンが押されたらローディングを開始してdeleteAllDataを呼び出す
                        isLoading = true
                        deleteAllData()
                    },
                    secondaryButton: .cancel(Text("キャンセル"))
                )
            case .error(let message):
                return Alert(
                    title: Text("エラー"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            case .none:
                return Alert(title: Text("不明なエラー"), message: Text("不明なエラーが発生しました。"), dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("アカウント削除")
        .toolbarColorScheme(.dark)
        .toolbarBackground(Color.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    func deleteAllData() {
        performSignInWithApple()
    }

    private func performSignInWithApple() {
        guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else {
            print("No key window available for presentation anchor.")
            return
        }
        signInWithAppleObject.signInWithApple(presentationAnchor: window) { result in
            switch result {
            case .success(let user):
                // Appleサインインが成功した場合、データ削除を実行
                authenticationManager.deleteAllData { result in
                    switch result {
                    case .success:
                        // 成功した場合にアカウントを削除
                        authenticationManager.deleteAccount { result in
                            switch result {
                            case .success:
                                path.removeAll()
                            case .failure(let error):
                                // アカウント削除に失敗した場合、エラーメッセージを表示
                                activeAlert = .error(error.localizedDescription)
                                showAlert = true
                            }
                            isLoading = false // ローディングを終了
                        }
                    case .failure(let error):
                        // データの削除に失敗した場合、エラーメッセージを表示
                        activeAlert = .error(error.localizedDescription)
                        showAlert = true
                        isLoading = false // ローディングを終了
                    }
                }
            case .failure(let error):
                // Appleサインインに失敗した場合、エラーメッセージを表示
                activeAlert = .error(error.localizedDescription)
                showAlert = true
                isLoading = false // ローディングを終了
            }
        }
    }
}

#Preview {
    NavigationStack {
        DeleteAccountView(path: .constant([]))
    }
}
