import SwiftUI

struct LikeButtonView: View {
    @Binding var isLiked: Bool
    @Binding var isButtonDisabled: Bool
    @Binding var likeCount: Int
    let buttonSize: CGSize
    var particleSize: CGSize {
        return CGSize(width: buttonSize.width * 2, height: buttonSize.height * 2)
    }
    let action: () -> Void
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Button(action: {
                withAnimation {
                    if !isLiked {
                        isAnimating = true
                    }
                    action()
                }
            }) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonSize.width, height: buttonSize.height)
                    .foregroundStyle(isLiked ? Color.pink : Color.white)
                    .overlay {
                        Text("\(likeCount)")
                            .font(.system(size: buttonSize.height/2))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                    }
            }
            .disabled(isButtonDisabled)

            ParticleEffectView(
                isAnimating: $isAnimating,
                particleSize: particleSize,
                buttonSize: buttonSize
            )
                .frame(width: buttonSize.width, height: buttonSize.height)
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var isLike = false
        @State var isButton = false
        @State var likeCount = 10
        var body: some View {
            LikeButtonView(
                isLiked: $isLike,
                isButtonDisabled: $isButton,
                likeCount: $likeCount,
                buttonSize: CGSize(width: 50, height: 50),
                action: {
                    isLike.toggle()
                }
            )
            .background {
                Color.cyan
            }
        }
    }
    return PreviewView()
}

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
    var endX: CGFloat
    var endY: CGFloat
    var color: Color
}

struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    @Binding var isAnimating: Bool
    let particleSize: CGSize
    let buttonSize: CGSize

    var body: some View {
        ZStack {
            ForEach(Array(particles.enumerated()), id: \.element.id) { index, particle in
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: particleSize.width / 3, height: particleSize.height / 3) // 大きさを調整
                    .foregroundColor(particle.color)
                    .scaleEffect(particle.scale)
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
        }
        .onChange(of: isAnimating) { newValue in
            if newValue {
                createParticles()
                withAnimation {
                    for index in particles.indices {
                        particles[index].x = particles[index].endX
                        particles[index].y = particles[index].endY
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.particles.removeAll()
                    }
                    self.isAnimating = false
                }
            }
        }
    }

    private func createParticles() {
        let particleCount = 8
        particles = (0..<particleCount).map { _ in
            let angle = Double.random(in: (.pi / 2)...(.pi)) // 上方向への角度を設定
            let distance = CGFloat.random(in: buttonSize.width...buttonSize.width*2)
            let hue = Double.random(in: 0...1) // 0から1の間でランダムに色相を決定
            return Particle(
                x: buttonSize.width / 2,  // 初期位置を中心に設定
                y: buttonSize.height / 2,  // 初期位置を中心に設定
                scale: CGFloat.random(in: 0.5...1.0),
                opacity: Double.random(in: 0.5...1.0),
                endX: buttonSize.width / 2 + distance * cos(angle),  // ランダムな方向へ
                endY: buttonSize.height / 2 - distance * sin(angle),   // 上方向へ移動
                color: Color(hue: hue, saturation: 1, brightness: 1) // 色相を使用して虹色を生成
            )
        }
    }
}
