import SwiftUI

struct MainColorEditView: View {
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockCardNavigationPath]
    @State private var selectedColor: Color = .mainColor
    let sampleColors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple, .pink]
    let mainColorEditViewModel = MainColorEditViewModel()

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 50)

            // ColorPicker
            Text("細かい色を選択")
                .font(.headline)
                .padding(.bottom, 5)
            ColorPicker("カラーパレットから細かく設定", selection: $selectedColor)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
                .padding(.bottom, 20)

            // Sample colors
            Text("おすすめの色")
                .font(.headline)
                .padding(.bottom, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(sampleColors, id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0))
                                .shadow(radius: selectedColor == color ? 1 : 0)
                                .padding(1)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)

            // Display selected colors
            Text("選択された色")
                .font(.headline)
                .padding(.bottom, 5)
            Rectangle()
                .fill(selectedColor)
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, 20)

            Spacer()

            // Confirm button
            Button(action: {
                mainColorEditViewModel.setMainColor(color: selectedColor)
                path.removeLast()
            }) {
                StrokeButtonUI(text: "決定", size: .large, isFill: false)
            }
            .padding(.horizontal)
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
        MainColorEditView(path: .constant([]))
    }
}
