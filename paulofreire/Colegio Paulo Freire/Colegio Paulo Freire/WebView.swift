import SwiftUI
import WebKit

struct StudentAreaFullScreenView: View {
    let url: URL

    var body: some View {
        WebScreen(url: url)
            .ignoresSafeArea()
    }
}

struct WebScreen: View {
    let url: URL
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var reloadToken = UUID()
    @State private var goBackToken = UUID()
    @State private var canGoBack = false
    @State private var showsStudentAreaReturnButton = false

    var body: some View {
        ZStack {
            WebView(
                url: url,
                isLoading: $isLoading,
                loadError: $loadError,
                reloadToken: reloadToken,
                goBackToken: goBackToken,
                canGoBack: $canGoBack,
                showsStudentAreaReturnButton: $showsStudentAreaReturnButton
            )

            if isLoading {
                ZStack {
                    Color.white.opacity(0.78)
                        .ignoresSafeArea()

                    VStack(spacing: 14) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(AppPalette.primaryNavy)
                            .scaleEffect(1.55)

                        Text("Carregando...")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppPalette.primaryNavy)
                    }
                    .padding(32)
                }
                .transition(.opacity)
            }

            if let loadError, !isLoading {
                ZStack {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()

                    VStack(spacing: 14) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Nao foi possivel abrir a pagina")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text(loadError)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.78))
                            .multilineTextAlignment(.center)

                        Button("Tentar novamente") {
                            self.loadError = nil
                            isLoading = true
                            reloadToken = UUID()
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppPalette.primaryNavy)
                        )
                    }
                    .padding(24)
                }
            }

            if showsStudentAreaReturnButton, !isLoading, loadError == nil {
                StudentAreaReturnButton {
                    loadError = nil
                    isLoading = true
                    canGoBack = false
                    showsStudentAreaReturnButton = false
                    goBackToken = UUID()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .animation(.easeInOut(duration: 0.2), value: showsStudentAreaReturnButton)
    }
}

private struct StudentAreaReturnButton: View {
    let action: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))

                        Text("Voltar")
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .foregroundColor(AppPalette.primaryNavy)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .overlay(
                                Capsule()
                                    .stroke(AppPalette.primaryNavy, lineWidth: 1.5)
                            )
                    )
                    .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 4)
                }
                .buttonStyle(.plain)

                Spacer()
            }

            Spacer()
        }
        .padding(.top, 52)
        .padding(.horizontal, 16)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadError: String?
    let reloadToken: UUID
    let goBackToken: UUID
    @Binding var canGoBack: Bool
    @Binding var showsStudentAreaReturnButton: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(
            isLoading: $isLoading,
            loadError: $loadError,
            canGoBack: $canGoBack,
            showsStudentAreaReturnButton: $showsStudentAreaReturnButton,
            lastReloadToken: reloadToken,
            lastGoBackToken: goBackToken,
            lastRequestedURL: url
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.userContentController.add(context.coordinator, name: "studentAreaBridge")
        configuration.userContentController.addUserScript(
            WKUserScript(
                source: context.coordinator.bulletinClickTrackingScript,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            )
        )
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.bounces = true
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
        DispatchQueue.main.async {
            isLoading = true
            loadError = nil
            canGoBack = webView.canGoBack
            showsStudentAreaReturnButton = false
        }
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastGoBackToken != goBackToken {
            context.coordinator.lastGoBackToken = goBackToken
            DispatchQueue.main.async {
                isLoading = true
                loadError = nil
                canGoBack = webView.canGoBack
                showsStudentAreaReturnButton = false
            }

            context.coordinator.clearBulletinTracking()
            if webView.canGoBack {
                webView.goBack()
            } else {
                DispatchQueue.main.async {
                    isLoading = false
                    canGoBack = false
                }
            }
            return
        }

        let shouldReload = context.coordinator.lastReloadToken != reloadToken
        let shouldLoadNewURL = context.coordinator.lastRequestedURL != url

        guard shouldReload || shouldLoadNewURL else { return }

        context.coordinator.lastReloadToken = reloadToken
        context.coordinator.lastRequestedURL = url
        DispatchQueue.main.async {
            isLoading = true
            loadError = nil
            canGoBack = webView.canGoBack
            showsStudentAreaReturnButton = false
        }
        webView.load(URLRequest(url: url))
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        @Binding private var isLoading: Bool
        @Binding private var loadError: String?
        @Binding private var canGoBack: Bool
        @Binding private var showsStudentAreaReturnButton: Bool
        var lastReloadToken: UUID
        var lastGoBackToken: UUID
        var lastRequestedURL: URL
        private var pendingReturnButtonNavigation = false

        init(
            isLoading: Binding<Bool>,
            loadError: Binding<String?>,
            canGoBack: Binding<Bool>,
            showsStudentAreaReturnButton: Binding<Bool>,
            lastReloadToken: UUID,
            lastGoBackToken: UUID,
            lastRequestedURL: URL
        ) {
            _isLoading = isLoading
            _loadError = loadError
            _canGoBack = canGoBack
            _showsStudentAreaReturnButton = showsStudentAreaReturnButton
            self.lastReloadToken = lastReloadToken
            self.lastGoBackToken = lastGoBackToken
            self.lastRequestedURL = lastRequestedURL
        }

        var bulletinClickTrackingScript: String {
            """
            (function() {
                if (window.__pauloFreireBulletinClickTrackingInstalled) {
                    return;
                }
                window.__pauloFreireBulletinClickTrackingInstalled = true;

                function normalize(value) {
                    return String(value || "")
                        .normalize("NFD")
                        .replace(/[\\u0300-\\u036f]/g, "")
                        .toUpperCase()
                        .replace(/\\s+/g, " ")
                        .trim();
                }

                function hasBulletinIntent(value) {
                    var normalized = normalize(value);
                    return normalized === "EMITIR BOLETIM" ||
                        normalized.indexOf("EMITIR BOLETIM") !== -1;
                }

                function hasBoletoIntent(value) {
                    var normalized = normalize(value);
                    return normalized.indexOf("BOLETO") !== -1 ||
                        normalized.indexOf("BOLETOS") !== -1 ||
                        normalized.indexOf("2 VIA") !== -1 ||
                        normalized.indexOf("2A VIA") !== -1 ||
                        normalized.indexOf("SEGUNDA VIA") !== -1 ||
                        normalized.indexOf("MENSALIDADE") !== -1;
                }

                function hasPrintIntent(value) {
                    var normalized = normalize(value);
                    return normalized.indexOf("IMPRIMIR") !== -1 ||
                        normalized.indexOf("IMPRESSAO") !== -1 ||
                        normalized.indexOf("PRINT") !== -1 ||
                        normalized.indexOf("PRINTER") !== -1 ||
                        normalized.indexOf("FA-PRINT") !== -1 ||
                        normalized.indexOf("BI-PRINTER") !== -1 ||
                        normalized.indexOf("GLYPHICON-PRINT") !== -1 ||
                        normalized.indexOf("ICON-PRINT") !== -1;
                }

                function valueOpensPdf(value) {
                    return String(value || "").toLowerCase().indexOf(".pdf") !== -1;
                }

                function controlSignals(element) {
                    var attributes = [
                        "href",
                        "src",
                        "action",
                        "formaction",
                        "data-href",
                        "data-url",
                        "data-link",
                        "data-target",
                        "data-action",
                        "data-original-title",
                        "data-title",
                        "aria-label",
                        "title",
                        "alt",
                        "name",
                        "id",
                        "class",
                        "onclick"
                    ];
                    var values = [
                        element.innerText,
                        element.textContent,
                        element.value
                    ];

                    for (var index = 0; index < attributes.length; index += 1) {
                        if (element.getAttribute) {
                            values.push(element.getAttribute(attributes[index]));
                        }
                    }

                    if (element.form && element.form.getAttribute) {
                        values.push(element.form.getAttribute("action"));
                        values.push(element.form.getAttribute("class"));
                        values.push(element.form.getAttribute("id"));
                    }

                    var children = element.querySelectorAll && element.querySelectorAll("i, svg, img, span");
                    if (children) {
                        for (var childIndex = 0; childIndex < children.length; childIndex += 1) {
                            var child = children[childIndex];
                            values.push(child.textContent);
                            values.push(child.getAttribute && child.getAttribute("class"));
                            values.push(child.getAttribute && child.getAttribute("id"));
                            values.push(child.getAttribute && child.getAttribute("title"));
                            values.push(child.getAttribute && child.getAttribute("aria-label"));
                            values.push(child.getAttribute && child.getAttribute("alt"));
                            values.push(child.getAttribute && child.getAttribute("data-icon"));
                        }
                    }

                    return values.join(" ");
                }

                function controlOpensPdf(element) {
                    return valueOpensPdf(controlSignals(element));
                }

                function hasReturnTargetIntent(element) {
                    var signals = controlSignals(element);
                    return hasBulletinIntent(signals) ||
                        hasBoletoIntent(signals) ||
                        controlOpensPdf(element) ||
                        hasPrintIntent(signals);
                }

                function isClickableControl(element) {
                    var tagName = normalize(element.tagName);
                    var role = normalize(element.getAttribute && element.getAttribute("role"));
                    return tagName === "A" ||
                        tagName === "BUTTON" ||
                        tagName === "INPUT" ||
                        role === "BUTTON" ||
                        role === "LINK" ||
                        element.onclick ||
                        element.getAttribute && element.getAttribute("tabindex") !== null;
                }

                document.addEventListener("click", function(event) {
                    var element = event.target;
                    while (element && element !== document.body) {
                        if (isClickableControl(element)) {
                            if (hasReturnTargetIntent(element)) {
                                window.webkit.messageHandlers.studentAreaBridge.postMessage({
                                    type: "willOpenReturnTarget",
                                    url: window.location.href
                                });
                            }
                            return;
                        }
                        element = element.parentElement;
                    }
                }, true);
            })();
            """
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
            loadError = nil
            canGoBack = webView.canGoBack
            showsStudentAreaReturnButton = false
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
            loadError = nil
            canGoBack = webView.canGoBack

            webView.evaluateJavaScript(
                "document.body ? document.body.innerText.trim().length + document.body.children.length : 0"
            ) { result, _ in
                guard let metric = result as? Int, metric == 0 else { return }
                if webView.url?.absoluteString == "about:blank" {
                    self.loadError = "A pagina abriu em branco dentro do app."
                }
            }

            updateStudentAreaReturnButtonVisibility(in: webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            guard !ignore(error) else { return }
            isLoading = false
            canGoBack = webView.canGoBack
            showsStudentAreaReturnButton = false
            loadError = error.localizedDescription
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            guard !ignore(error) else { return }
            isLoading = false
            canGoBack = webView.canGoBack
            showsStudentAreaReturnButton = false
            loadError = error.localizedDescription
        }

        private func ignore(_ error: Error) -> Bool {
            let nsError = error as NSError
            return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if let url = navigationAction.request.url, isReturnTargetURL(url) {
                pendingReturnButtonNavigation = true
            }

            decisionHandler(.allow)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                if let url = navigationAction.request.url, isReturnTargetURL(url) {
                    pendingReturnButtonNavigation = true
                }
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            isLoading = true
            canGoBack = webView.canGoBack
            showsStudentAreaReturnButton = false
            webView.reload()
        }

        func clearBulletinTracking() {
            pendingReturnButtonNavigation = false
        }

        private func updateStudentAreaReturnButtonVisibility(in webView: WKWebView) {
            let shouldShowButton = pendingReturnButtonNavigation || webView.url.map(isReturnTargetURL) == true
            pendingReturnButtonNavigation = false
            canGoBack = webView.canGoBack
            showsStudentAreaReturnButton = shouldShowButton
        }

        private func isReturnTargetURL(_ url: URL) -> Bool {
            let absoluteString = url.absoluteString.lowercased()
            return isPDFURL(url) ||
                absoluteString.contains("boleto") ||
                absoluteString.contains("boletos") ||
                absoluteString.contains("segunda-via") ||
                absoluteString.contains("2-via") ||
                absoluteString.contains("2avia") ||
                absoluteString.contains("impressao")
        }

        private func isPDFURL(_ url: URL) -> Bool {
            url.pathExtension.lowercased() == "pdf" ||
                url.absoluteString.lowercased().contains(".pdf")
        }
    }
}

extension WebView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "studentAreaBridge",
              let body = message.body as? [String: Any],
              let type = body["type"] as? String,
              ["willOpenBulletin", "willOpenReturnTarget"].contains(type) else {
            return
        }

        pendingReturnButtonNavigation = true
    }
}
