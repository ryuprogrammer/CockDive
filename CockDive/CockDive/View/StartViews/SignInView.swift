import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @State private var signInWithAppleObject = SignInWithAppleObject()

    @State private var isShowSheet = false
    @State private var showViewType: ShowViewType? = nil
    @State private var isLoading = false // ローディング状態を管理

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

                Text("みんなのごはん")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)

                Spacer()

                LongBarButton(text: "Appleでサインイン", isStroke: true) {
                    performSignInWithApple()
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
            if isLoading {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
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

    private func performSignInWithApple() {
        isLoading = true // ローディングを開始
        guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else {
            print("No key window available for presentation anchor.")
            isLoading = false // ローディングを終了
            return
        }
        signInWithAppleObject.signInWithApple(presentationAnchor: window) { result in
            isLoading = false // ローディングを終了
            switch result {
            case .success(let user):
                print("User signed in: \(user.uid), email: \(user.email ?? "No email")")
                // 成功時の処理をここに追加
            case .failure(let error):
                print("Error during sign in with Apple: \(error.localizedDescription)")
                // エラー時の処理をここに追加
            }
        }
    }
}

#Preview {
    SignInView()
}
