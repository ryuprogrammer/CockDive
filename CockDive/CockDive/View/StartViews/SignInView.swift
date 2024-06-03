import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @State private var signInWithAppleObject = SignInWithAppleObject()

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

                Text("みんなのごはん")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)

                Spacer()

                LongBarButton(text: "サインイン", isStroke: true) {
                    self.isShowSheet.toggle()
                }

                LongBarButton(text: "Appleでサインイン", isStroke: true) {
                    performSignInWithApple()
                }

                Button {
                    performSignInWithApple()
                } label: {
                    SignInWithAppleButton()
                        .frame(height: 50)
                        .cornerRadius(16)
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

    private func performSignInWithApple() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            print("No key window available for presentation anchor.")
            return
        }
        signInWithAppleObject.signInWithApple(presentationAnchor: window)
    }
}

struct SignInWithAppleButton: UIViewRepresentable {
    typealias UIViewType = ASAuthorizationAppleIDButton

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}

#Preview {
    SignInView()
}
