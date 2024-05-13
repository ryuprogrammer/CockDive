import SwiftUI

struct DynamicHeightTextEditorView: View {
    @Binding var text: String
    let placeholder: String
    let maxHeight: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            // プレースホルダー
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 5)
            }

            // テキストエディター
            HStack {
                Text(text.isEmpty ? "placeholder" : text)
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
        .frame(maxHeight: maxHeight) // テキストエディタの最大サイズを設定する
        .fixedSize(horizontal: false, vertical: true) // テキストエディタの最大サイズを設定する
        .background(Color.white) // テキストエディタの背景色
        .mask(RoundedRectangle(cornerRadius: 18).padding(.vertical, 3))
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
        }
        .onDisappear {
            UITextView.appearance().backgroundColor = nil
        }
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
