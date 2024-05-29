import SwiftUI

struct SignInView: View {
    @State private var isShowSheet = false
    @State private var showViewType: ShowViewType? = nil
    @State private var isLoading = true

    private enum ShowViewType: Identifiable {
        case privacyPolicyView
        case termsOfServiceView

        var id: Self { self }
    }

    var body: some View {
        ZStack {
            Color.mainColor
            VStack {
                Spacer()
                
                Text("みんなのご飯")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                // Sign-Out状態なのでSign-Inボタンを表示する
                LongBarButton(text: "サインイン", isStroke: true) {
                    self.isShowSheet.toggle()
                }

                HStack {
                    Button {
                        showViewType = .termsOfServiceView
                    } label: {
                        Text("利用規約")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                    }

                    Button {
                        showViewType = .privacyPolicyView
                    } label: {
                        Text("プライバシーポリシー")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                    }
                }

                Spacer()
                    .frame(height: 100)
            }
        }
        .ignoresSafeArea(.all)
        .sheet(isPresented: $isShowSheet) {
            FirebaseAuthUIView()
        }
        .sheet(item: $showViewType) { type in
            switch type {
            case .privacyPolicyView:
                PrivacyPolicyView(path: .constant([]))
            case .termsOfServiceView:
                TermsOfServiceView(path: .constant([]))
            }
        }
    }
}

#Preview {
    SignInView()
}
