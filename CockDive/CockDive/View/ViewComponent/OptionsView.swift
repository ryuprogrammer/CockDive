import SwiftUI

enum OptionType {
    case comment
    case post
}

struct OptionsView: View {
    /// 自分のデータか
    let isMyData: Bool
    /// true: 常に白/ false: lightでは黒、darkでは白
    let isAlwaysWhite: Bool
    /// navigationBarで使用する際はfalseで大きくなる
    let isSmall: Bool
    /// コメントか投稿か
    let optionType: OptionType
    let blockAction: () -> Void
    let reportAction: () -> Void
    let editAction: () -> Void
    let deleteAction: () -> Void

    @State private var showActionSheet: Bool = false

    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    var imageSize: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            let size = CGFloat(isSmall ? 20 : 16)
            return (screen.bounds.width) / size
        }
        return 20
    }

    var body: some View {
        if isMyData {
            Button {
                showActionSheet = true
            } label: {
                if isAlwaysWhite {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: imageSize, height: imageSize)
                        .foregroundStyle(Color.white)
                } else {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: imageSize, height: imageSize)
                        .foregroundStyle(Color.blackWhite)
                }
            }
            .actionSheet(isPresented: $showActionSheet) {
                getActionSheet()
            }
        } else {
            Menu {
                getMenu()
            } label: {
                if isAlwaysWhite {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: imageSize, height: imageSize)
                        .foregroundStyle(Color.white)
                } else {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: imageSize, height: imageSize)
                        .foregroundStyle(Color.blackWhite)
                }
            }
        }
    }

    private func getActionSheet() -> ActionSheet {
        switch optionType {
        case .comment:
            return ActionSheet(
                title: Text("コメントを削除しますか？"),
                buttons: [
                    .destructive(Text("削除する"), action: deleteAction),
                    .cancel(Text("キャンセル"))
                ]
            )
        case .post:
            return ActionSheet(
                title: Text("投稿オプション"),
                buttons: [
                    .default(Text("投稿を編集する"), action: editAction),
                    .destructive(Text("投稿を削除する"), action: deleteAction),
                    .cancel(Text("キャンセル"))
                ]
            )
        }
    }

    @ViewBuilder
    private func getMenu() -> some View {
        Button(action: blockAction) {
            Label("ブロック", systemImage: "hand.raised")
        }
        Button(action: reportAction) {
            Label("通報", systemImage: "exclamationmark.bubble")
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("自分のコメント→白黒")

            OptionsView(
                isMyData: true,
                isAlwaysWhite: false,
                isSmall: true,
                optionType: .comment,
                blockAction: { print("ブロック") },
                reportAction: { print("通報") },
                editAction: { print("編集") },
                deleteAction: { print("削除") }
            )

            Text("自分の投稿")

            OptionsView(
                isMyData: true,
                isAlwaysWhite: false,
                isSmall: true,
                optionType: .post,
                blockAction: {
                    print("ブロック")
                },
                reportAction: { print("通報") },
                editAction: { print("編集") },
                deleteAction: { print("削除") }
            )

            Text("他人のコメント→白黒")

            OptionsView(
                isMyData: false,
                isAlwaysWhite: false,
                isSmall: true,
                optionType: .comment,
                blockAction: { print("ブロック") },
                reportAction: { print("通報") },
                editAction: { print("編集") },
                deleteAction: { print("削除") }
            )

            Text("他人の投稿→タブなら白, タブ以外なら")
            
            OptionsView(
                isMyData: false,
                isAlwaysWhite: false,
                isSmall: true,
                optionType: .post,
                blockAction: { print("ブロック") },
                reportAction: { print("通報") },
                editAction: { print("編集") },
                deleteAction: { print("削除") }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
