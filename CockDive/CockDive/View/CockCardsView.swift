import SwiftUI

struct CockCardsView: View {
    var body: some View {
        List {
            ForEach(0..<10) { _ in
                CockCardView()
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    CockCardsView()
}
