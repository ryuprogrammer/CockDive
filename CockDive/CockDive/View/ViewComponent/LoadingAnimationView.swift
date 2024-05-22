import SwiftUI

// ブロッコリーがジャンプ
struct LoadingAnimationView: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(0..<4) { i in
                Text("🥦")
                    .font(.largeTitle)
                    .offset(y: self.isAnimating ? -10 : 10)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.1),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            withAnimation {
                self.isAnimating = true
            }
        }
        .frame(width: 200, height: 100)
    }
}

#Preview {
    LoadingAnimationView()
}
