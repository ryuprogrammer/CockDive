import SwiftUI

struct AdvertisementBarView: View {
    @State private var gradientColors: [Color] = [.blue, .blue, .green]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .leading,
                endPoint: .trailing
            )
            .opacity(0.5)
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .onAppear {
                animateColors()
            }

            Text("カレンダーを埋め尽くそう！")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
        }
    }

    private func animateColors() {
        let baseColors: [[Color]] = [
            [.blue, .blue, .green],
            [.green, .blue, .blue, .green],
            [.green, .blue, .blue]
        ]

        var index = 0
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 2.0)) {
                index = (index + 1) % baseColors.count
                gradientColors = baseColors[index]
            }
        }
    }
}

#Preview {
    AdvertisementBarView()
}
