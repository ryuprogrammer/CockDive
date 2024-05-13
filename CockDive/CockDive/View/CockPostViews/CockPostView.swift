import SwiftUI

struct CockPostView: View {
    // 投稿追加画面の表示有無
    @State private var isShowSheet: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(0..<10) { _ in
                        CockCardView()
                    }
                }
                .listStyle(.plain)
                
                Button(action: {
                    isShowSheet = true
                }, label: {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: 65, height: 65)
                        .foregroundStyle(Color.white)
                        .background(Color("main"))
                        .clipShape(Circle())
                })
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottomTrailing
                )
                .padding()
            }
            .navigationTitle("みんなのご飯")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("main"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $isShowSheet) {
            AddPostView()
        }
    }
}

#Preview {
    CockPostView()
}
