import SwiftUI

struct DynamicHeightCommentView: View {
    // 表示するメッセージを定義します。
    let message: String
    // 表示する最大文字数
    let maxTextCount: Int = 40

    // メッセージの表示状態を制御するための状態変数です。
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading) {
            // メッセージを表示します。`isExpanded`の値に応じて行数の制限を変更します。
            Text(fullText)
                // 行数制限を設定します。
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
        }
    }

    private var fullText: AttributedString {
        if !isExpanded && message.count > maxTextCount {
            let truncatedMessage = message.prefix(maxTextCount)
            var attributedString = AttributedString("\(truncatedMessage)... 続きを見る")
            if let range = attributedString.range(of: "続きを見る") {
                attributedString[range].foregroundColor = .blue
            }
            return attributedString
        }
        return AttributedString(message)
    }
}

#Preview {
    VStack {
        // 長いバージョン
        DynamicHeightCommentView(message: "長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示")
        Spacer()
            .frame(height: 200)
        // 15文字以下のバージョン
        DynamicHeightCommentView(message: "長い文章を表長い文章を表長い文章を表長い文章を表長い文章を表長い文章を表長い文章を表")
    }
}
