//
//  LongCommentView.swift
//  CockDive
//
//  Created by トム・クルーズ on 2024/05/13.
//

import SwiftUI

struct LongCommentView: View {
    // 表示するメッセージを定義します。
      let message: String
      
      // メッセージの表示状態を制御するための状態変数です。
      @State private var isExpanded = false

      var body: some View {
        HStack(spacing: 0) {
          Text(message)
            // 行数制限を設定します。
            // ここでは初期表示1行で設定しています。
            .lineLimit(isExpanded ? nil : 1)
            // アニメーションを設定します。
            .animation(.easeInOut, value: isExpanded)
            // テキストがオーバーフローした場合、末尾を省略します。
            .truncationMode(.tail)
            // テキストが適切に折り返されるようにします。
            .fixedSize(horizontal: false, vertical: true)
            // テキストを左揃えに設定し、展開時に横幅を広げます。
            .frame(maxWidth: isExpanded ? .infinity : nil, alignment: .leading)
            .onTapGesture {
                isExpanded = false
            }

          // メッセージが展開されていない場合、「続きを見る」ボタンを表示します。
            if !isExpanded && message.count >= 15 {
            Button(action: {
              // ボタンが押されると、メッセージの表示状態を切り替えます。
              isExpanded.toggle()
            }) {
              Text("続きを読む")
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
}

#Preview {
    VStack {
        // 長いバージョン
        LongCommentView(message: "長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示")
        Spacer()
            .frame(height: 200)
        // 15文字以下のバージョン
        LongCommentView(message: "長い文章を表")
    }
}
