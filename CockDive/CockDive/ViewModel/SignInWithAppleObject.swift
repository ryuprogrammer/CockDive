import AuthenticationServices
import CryptoKit
import FirebaseAuth

public class SignInWithAppleObject: NSObject {
    private var currentNonce: String?
    private var completion: ((Result<User, Error>) -> Void)?

    public func signInWithApple(presentationAnchor: ASPresentationAnchor, completion: @escaping (Result<User, Error>) -> Void) {
        self.completion = completion

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.map {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

extension SignInWithAppleObject: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        handleAuthorization(authorization)
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error.localizedDescription)")
        completion?(.failure(error))
    }

    private func handleAuthorization(_ authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Failed to retrieve Apple ID Credential")
            completion?(.failure(NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve Apple ID Credential"])))
            return
        }

        guard let nonce = currentNonce else {
            print("Invalid state: A login callback was received, but no login request was sent.")
            completion?(.failure(NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."])))
            return
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            completion?(.failure(NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data")
            completion?(.failure(NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string from data"])))
            return
        }

        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print("Error during Firebase sign in: \(error.localizedDescription)")
                self.completion?(.failure(error))
                return
            }

            // Successful sign in handling
            if let user = result?.user {
                print("User signed in: \(user.uid), email: \(user.email ?? "No email")")
                self.completion?(.success(user))
            }
        }
    }

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 適切なプレゼンテーションアンカーを返す
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No active window scene found")
        }
        return window
    }
}
