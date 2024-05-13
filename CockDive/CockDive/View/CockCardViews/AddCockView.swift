import SwiftUI

struct AddCockView: View {
    @State private var title: String = ""
    @State private var memo: String = ""
    @State private var canSeeEveryone: Bool = true
    
    // 画面サイズ取得
    let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
    // キーボード制御
    @FocusState private var keybordFocuse: Bool
    // モーダル制御
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { reader in
                    List {
                        Section {
                            Button(action: {
                                
                            }, label: {
                                Text("写真を追加")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .background(Color.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            })
                        } header: {
                            Text("①写真: まずは写真を追加しよう 必須")
                        }
                        .listRowSeparator(.hidden)
                        
                        Section {
                            TextField("料理名を入力", text: $title)
                                .padding(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.6)
                                )
                        } header: {
                            Text("②料理名: 何を食べたの？ 必須")
                        }
                        .listRowSeparator(.hidden)
                        
                        Section {
                            TextEditor(text: $memo)
                                .focused($keybordFocuse)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.6)
                                )
                                .overlay(alignment: .topLeading) {
                                    Text(memo == "" ? "ご飯のメモ\n 例） 旬の野菜を取り入れてみました。" : "")
                                        .foregroundStyle(Color.gray.opacity(0.5))
                                        .padding(5)
                                }
                                .onTapGesture {
                                    keybordFocuse.toggle()
                                }
                                .id(1)
                                .onChange(of: keybordFocuse) {_ in
                                    withAnimation {
                                        reader.scrollTo(1, anchor: .top)
                                    }
                                }
                        } header: {
                            Text("③メモ: ご飯のメモをしよう")
                        }
                        .listRowSeparator(.hidden)
                        
                        Section {
                            Toggle(canSeeEveryone ? "みんなに公開" : "非公開", isOn: $canSeeEveryone)
                                .toggleStyle(.switch)
                        } header: {
                            Text("③公開範囲: 誰に見てもらう？")
                        }
                        .listRowSeparator(.hidden)
                        
                        Spacer()
                            .frame(height: 10)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
                
                VStack {
                    Spacer()
                    // 投稿ボタン
                    LongBarButton(text: "投稿する") {
                        dismiss()
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
