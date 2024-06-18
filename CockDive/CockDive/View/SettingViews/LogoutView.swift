import SwiftUI

struct LogoutView: View {
    @Binding var path: [CockCardNavigationPath]
    @ObservedObject var authenticationManager = AuthenticationManager()
    @State private var showAlert = false

    let logoutWarningMessage = """
ログアウトについて

ログアウトを行うと、以下の点にご注意ください。

✅ すべてのセッションが終了します。
✅ アプリを削除した場合はデータが削除される場合があります。
✅ 再ログインには、再度認証情報が必要です。

本当にログアウトしますか？

もし、ログアウトについてお困りのことがございましたら、サポートチームまでご連絡ください。ログアウト以外の方法で解決できる可能性があります。

サポートチーム連絡先：「設定」→「お問い合わせ」

ログアウトをやめる場合は、「キャンセル」ボタンをクリックしてください。

それでもログアウトする場合は、「はい」ボタンをクリックしてください。
"""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(logoutWarningMessage)

                Spacer()
                
                Button(action: {
                    showAlert = true
                }) {
                    Text("ログアウト")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("ログアウト確認"),
                message: Text("本当にログアウトしますか？"),
                primaryButton: .cancel(Text("キャンセル")),
                secondaryButton: .destructive(Text("はい")) {
                    authenticationManager.signOut()
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("ログアウト")
        .toolbarColorScheme(.dark)
        .toolbarBackground(Color.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        LogoutView(path: .constant([]))
    }
}
