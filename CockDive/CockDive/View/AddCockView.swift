import SwiftUI

struct AddCockView: View {
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        Button(action: {
                            
                        }, label: {
                            Text("写真を追加")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        })
                    } header: {
                        Text("①写真: まずは写真を追加しよう")
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                
                VStack {
                    Spacer()
                    // 投稿ボタン
                    LongBarButton(text: "投稿する") {
                        
                    }
                }
            }
            .navigationTitle("ご飯を投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    AddCockView()
}
