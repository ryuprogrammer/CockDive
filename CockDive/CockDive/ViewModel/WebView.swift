import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

struct WepViewPreviewView: View {
    @State private var isLoading = true

    var body: some View {
        ZStack {
            WebView(urlString: "https://minnanogohan.hp.peraichi.com/privacypolicy", isLoading: $isLoading)
                .edgesIgnoringSafeArea(.all)

            if isLoading {
                ProgressView("読み込んでるよ")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}

#Preview {
    WepViewPreviewView()
}
