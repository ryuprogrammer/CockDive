import SwiftUI

struct DynamicHeightCommentView: View {
    let message: String
    @State private var isExpanded = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(message)
                .lineLimit(isExpanded ? nil : 2)
                .animation(.easeInOut, value: isExpanded)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !isExpanded && message.count > 40 {
                Button(action: {
                    isExpanded.toggle()
                }) {
                    Text("     続きを読む")
                        .foregroundColor(.blue)
                        .padding(.leading, 5)
                        .background(Color.whiteBlack.blur(radius: 5))
                        .cornerRadius(5)
                }
            }
        }
        .onTapGesture {
            if isExpanded {
                isExpanded.toggle()
            }
        }
    }
}

#Preview {
    VStack {
        // 改行ありの長いバージョン
        DynamicHeightCommentView(message: "長い文章\nを表示長い文章を表示長\nい文章を表示長い文章を表示\n長い文章を表示長い文章を表示長い文章を表示長い文章を表示長い文章を表示")
        Spacer()
            .frame(height: 200)
        // 長いバージョン
        DynamicHeightCommentView(message: "長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章長い文章")
        Spacer()
            .frame(height: 200)
        // 短いバージョン
        DynamicHeightCommentView(message: "短い文章")
    }
}
