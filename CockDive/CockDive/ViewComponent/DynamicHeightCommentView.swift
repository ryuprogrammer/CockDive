import SwiftUI

struct DynamicHeightCommentView: View {
    // 表示するメッセージを定義します。
      let message: String
    // 表示する最大文字数
    let maxTextCount: Int
      
      // メッセージの表示状態を制御するための状態変数です。
      @State private var isExpanded = false

      var body: some View {
        VStack(alignment: .leading) {
          // メッセージを表示します。`isExpanded`の値に応じて行数の制限を変更します。
          Text(message)
            // 行数制限を設定します。
            // ここでは初期表示2行で設定しています。
            .lineLimit(isExpanded ? nil : 2)
            // アニメーションを設定します。
            .animation(.easeInOut, value: isExpanded)
            // テキストが適切に折り返されるようにします。
            .fixedSize(horizontal: false, vertical: true)
            // テキストを左揃えにします。
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                isExpanded.toggle()
            }

          // メッセージが展開されていない場合、「続きを見る」ボタンを表示します。
            if !isExpanded && message.count > maxTextCount {
            Button(action: {
              // ボタンが押されると、メッセージの表示状態を切り替えます。
              isExpanded.toggle()
            }) {
              Text("続きを見る")
                .foregroundColor(.secondary)
            }
          }
        }
      }
}

#Preview {
    VStack {
        // 長いバージョン
        DynamicHeightCommentView(message: "長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示", maxTextCount: 15)
        Spacer()
            .frame(height: 200)
        // 15文字以下のバージョン
        DynamicHeightCommentView(message: "長い文章を表", maxTextCount: 15)
    }
}
