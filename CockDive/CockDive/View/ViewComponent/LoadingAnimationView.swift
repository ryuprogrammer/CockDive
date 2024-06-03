import SwiftUI

struct LoadingAnimationView: View {
    @State private var foodEmojis = ["🥦", "🍎", "🥕", "🍆", "🍓", "🍌", "🥑", "🍉"]
    @State private var currentEmoji = "🥦"
    @State private var shake = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 3) {
            Text(self.currentEmoji)
                .font(.largeTitle)
                .rotationEffect(.degrees(shake ? 10 : -10))
                .animation(Animation.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true), value: shake)
                .onAppear {
                    startShakingAndChangeEmoji()
                }
                .onDisappear {
                    timer?.invalidate()
                    timer = nil
                }
            Text("ロード中 ")
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(width: 200, height: 100)
    }

    private func startShakingAndChangeEmoji() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation {
                shake.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                var newEmoji: String
                repeat {
                    newEmoji = self.foodEmojis.randomElement()!
                } while newEmoji == self.currentEmoji
                withAnimation {
                    self.currentEmoji = newEmoji
                }
            }
        }
    }
}

#Preview {
    LoadingAnimationView()
}
