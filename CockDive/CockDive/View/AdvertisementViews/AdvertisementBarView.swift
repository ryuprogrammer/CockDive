import SwiftUI

struct AdvertisementBarView: View {
    @State private var gradientColors: [Color] = [.pink, .pink, .red]
    @State private var showHeart = false
    @State private var bounce = false
    @State private var colorTimer: Timer?
    @State private var heartTimer: Timer?

    let postCount: Int

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .leading,
                endPoint: .trailing
            )
            .opacity(0.7)
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .onAppear {
                resetTimers()
                animateColors()
                animateHeart()
            }
            .onDisappear {
                resetTimers()
            }

            HStack {
                Text(getMessage(for: postCount))
                    .font(.mainFont(size: 27))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)

                if showHeart {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .scaleEffect(bounce ? 1.5 : 1.2)
                        .offset(y: bounce ? -10 : 3)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true),
                            value: bounce
                        )
                        .transition(.scale)
                }
            }
        }
    }

    private func getMessage(for count: Int) -> String {
        switch count {
        case 0:
            return "投稿していいねをもらおう"
        case 1...5:
            return "コメントしてみよう"
        case 6...10:
            return "カレンダーを埋め尽くそう"
        default:
            return "毎日頑張ってえらすぎる"
        }
    }

    private func animateColors() {
        let baseColors: [[Color]] = [
            [.pink, .pink, .red],
            [.pink, .pink, .pink, .red],
            [.red, .pink, .pink]
        ]

        var index = 0
        colorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 2.0)) {
                index = (index + 1) % baseColors.count
                gradientColors = baseColors[index]
            }
        }
    }

    private func animateHeart() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showHeart = true
            }

            heartTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                bounce.toggle()
            }
        }
    }

    private func resetTimers() {
        colorTimer?.invalidate()
        colorTimer = nil
        heartTimer?.invalidate()
        heartTimer = nil
        showHeart = false
        bounce = false
    }
}

#Preview {
    VStack {
        AdvertisementBarView(postCount: 0)
        AdvertisementBarView(postCount: 3)
        AdvertisementBarView(postCount: 10)
        AdvertisementBarView(postCount: 100)
    }
}
