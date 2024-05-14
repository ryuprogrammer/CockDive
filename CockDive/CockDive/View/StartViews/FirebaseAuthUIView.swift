import SwiftUI
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
//import FirebaseFacebookAuthUI
//import FirebasePhoneAuthUI

struct FirebaseAuthUIView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let authUI = FUIAuth.defaultAuthUI()!
        // サポートするログイン方法を構成
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(authUI: authUI),
//            FUIFacebookAuth(authUI: authUI),
//            FUIOAuth.twitterAuthProvider(),
//            FUIPhoneAuth(authUI:authUI),
            FUIOAuth.appleAuthProvider(),
        ]
        authUI.providers = providers
        
        // FirebaseUIを表示する
        let authViewController = authUI.authViewController()
        
        return authViewController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // 処理なし
    }
}
