import SwiftUI

struct DynamicHeightTextEditorView: View {
    // 入力するテキスト
    @Binding var text: String
    // プレースホルダーの文字
    let placeholder: String
    // 最大の高さ
    let maxHeight: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            // テキストエディター
            HStack {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                } else {
                    Text(text)
                }
                Spacer(minLength: 0)
            }
            .allowsHitTesting(false)
            .foregroundColor(.clear)
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
            .background(
                TextEditor(text: $text)
                    .offset(y: 1.8)
            )
        }
        .padding(.horizontal, 10)
        .frame(maxHeight: maxHeight)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.white)
        .mask(RoundedRectangle(cornerRadius: 18).padding(.vertical, 3))
    }
}


#Preview {
    struct PreviewView: View {
        @State private var text: String = ""

        var body: some View {
            HStack {
                DynamicHeightTextEditorView(
                    text: $text,
                    placeholder: "入力してください。",
                    maxHeight: 200
                )
            }
            .padding()
            .background(Color.mainColor)
        }
    }
    return PreviewView()
}

