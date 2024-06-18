import SwiftUI

struct MainColorEditView: View {
    @State private var selectedColor: Color = .mainColor
    let sampleColors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple, .pink]

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 100)
            // ColorPicker
            ColorPicker("Pickerから細かく設定", selection: $selectedColor)
                .padding()

            // Sample colors
            Text("おすすめの色")
                .padding(.top)

            HStack {
                ForEach(sampleColors, id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                    }) {
                        Circle()
                            .fill(color)
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .padding()

            // Display selected color
            Rectangle()
                .fill(selectedColor)
                .frame(width: 100, height: 100)
                .padding()

            Spacer()

            // Confirm button
            Button(action: {
                print("Selected color confirmed: \(selectedColor.description)")
                // ここに決定ボタンが押された時のアクションを追加
            }) {
                StrokeButtonUI(text: "決定", size: .large, isFill: false)
            }
            .padding(.top)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("テーマカラーを変更")
        .toolbarColorScheme(.dark)
        .toolbarBackground(Color.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        MainColorEditView()
    }
}
