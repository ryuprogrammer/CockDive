import SwiftUI

struct MainColorEditView: View {
    // ルート階層から受け取った配列パスの参照
    @Binding var path: [CockCardNavigationPath]
    @State private var selectedColor: Color = .mainColor
    @State private var showError: Bool = false
    let sampleColors: [Color] = [
        .red, .green, .orange, .pink,
        .cyan, .indigo, .mint, .main
    ]
    let mainColorEditViewModel = MainColorEditViewModel()

    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    var circleSize: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let screen = windowScene.windows.first?.screen {
            return screen.bounds.width / 7
        }
        return 50
    }

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 50)

            // Sample colors
            Text("色をタップして選択してね！")
                .font(.headline)
                .padding(.bottom, 5)

            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 15) {
                ForEach(sampleColors, id: \.self) { color in
                    Button(action: {
                        if color != .white && color != .black {
                            selectedColor = color
                            showError = false
                        } else {
                            showError = true
                        }
                    }) {
                        Circle()
                            .fill(color)
                            .frame(width: circleSize, height: circleSize)
                            .overlay(Circle().stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0))
                            .shadow(
                                color: selectedColor == color ? color : .clear,
                                radius: selectedColor == color ? 5 : 0
                            )
                            .padding(1)
                    }
                }
            }
            .padding()

            Spacer()
                .frame(height: 50)

            // Display selected colors
            Text("選択された色")
                .font(.headline)
                .padding(.bottom, 5)
            Rectangle()
                .fill(selectedColor)
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .shadow(radius: 5)

            Spacer()
                .frame(height: 100)

            Text("テーマカラーはすぐに更新されない場合があります。")
            // Confirm button
            Button(action: {
                if selectedColor != .white && selectedColor != .black {
                    mainColorEditViewModel.setMainColor(color: selectedColor)
                    path.removeLast()
                }
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

