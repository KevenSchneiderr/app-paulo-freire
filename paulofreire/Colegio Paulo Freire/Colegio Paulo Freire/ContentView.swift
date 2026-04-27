import SwiftUI

enum AppPalette {
    static let background = Color.white
    static let primaryNavy = Color(red: 8/255, green: 38/255, blue: 84/255)
    static let deepNavy = Color(red: 5/255, green: 31/255, blue: 70/255)
    static let paleBlue = Color(red: 236/255, green: 246/255, blue: 253/255)
    static let softGray = Color(red: 246/255, green: 246/255, blue: 246/255)
    static let mutedText = Color(red: 137/255, green: 141/255, blue: 148/255)
}

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @State private var selectedURL: URL?
    @State private var showWebView = false
    @State private var showStudentArea = false
    @State private var showStudentAreaLoading = false

    var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width
            let screenHeight = proxy.size.height
            let compactWidth = screenWidth < 375
            let compactHeight = screenHeight < 760
            let horizontalPadding = max(16, min(screenWidth * 0.05, 28))
            let contentWidth = min(screenWidth - (horizontalPadding * 2), 360)
            let logoWidth = compactWidth ? 104.0 : 122.0
            let titleSize = compactWidth ? 31.0 : 34.0
            let titleTopPadding = compactHeight ? 24.0 : 30.0
            let topSpacing = compactHeight ? 18.0 : 28.0
            let bannerHeight = compactWidth ? 150.0 : 168.0
            let bannerTopPadding = compactHeight ? 18.0 : 22.0
            let captionFontSize = compactWidth ? 15.0 : 15.0
            let primaryButtonHeight = compactWidth ? 62.0 : 68.0
            let secondaryButtonHeight = compactWidth ? 48.0 : 52.0
            let socialTopPadding = compactHeight ? 36.0 : 44.0
            let socialSpacing = compactWidth ? 24.0 : 30.0
            let socialIconSize = compactWidth ? 32.0 : 36.0
            let socialSymbolSize = compactWidth ? 20.0 : 24.0
            let footerHeight = compactWidth ? 28.0 : 30.0

            ZStack {
                AppPalette.background
                    .ignoresSafeArea()

                AnimatedBackgroundCircles()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: topSpacing)

                            Image("cppf_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: logoWidth)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Bem-vindo,")
                                    .font(.system(size: titleSize, weight: .bold))
                                    .foregroundColor(AppPalette.primaryNavy)

                                Text("Aluno")
                                    .font(.system(size: titleSize, weight: .bold))
                                    .foregroundColor(AppPalette.primaryNavy)
                            }
                            .frame(width: contentWidth, alignment: .leading)
                            .padding(.top, titleTopPadding)

                            Image("students_banner")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 144)
                                .frame(width: contentWidth)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .clipped()
                                .padding(.top, bannerTopPadding)

                            Text("Clique abaixo para continuar seu acesso")
                                .font(.system(size: captionFontSize, weight: .medium))
                                .foregroundColor(AppPalette.mutedText)
                                .multilineTextAlignment(.center)
                                .padding(.top, 18)
                                .padding(.horizontal, horizontalPadding)

                            Button {
                                openStudentArea()
                            } label: {
                                ZStack {
                                    Image("acess_button_bg")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: contentWidth, height: primaryButtonHeight)
                                        .overlay(
                                            AppPalette.primaryNavy.opacity(0.6)
                                        )

                                    HStack(spacing: 10) {
                                        Image(systemName: "book.fill")
                                            .font(.system(size: compactWidth ? 15 : 16, weight: .semibold))
                                        Text("Acessar área do aluno")
                                            .font(.system(size: compactWidth ? 15 : 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                }
                                .frame(width: contentWidth, height: primaryButtonHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .padding(.top, 25)

                            Button {
                                openExternalLink("https://cppaulofreire.com.br/site/")
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "globe")
                                        .font(.system(size: compactWidth ? 14 : 15, weight: .semibold))

                                    Text("Visitar site oficial")
                                        .font(.system(size: compactWidth ? 15 : 16, weight: .semibold))
                                }
                                .foregroundColor(AppPalette.primaryNavy)
                                .frame(width: contentWidth, height: secondaryButtonHeight)
                                .background(AppPalette.background)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(AppPalette.primaryNavy, lineWidth: 1.5)
                                )
                            }
                            .padding(.top, 18)

                            HStack(spacing: socialSpacing) {
                                socialIcon(
                                    imageName: "facebook",
                                    urlString: "https://www.facebook.com/COLEGIOPROFESSORPAULOFREIRE/",
                                    iconSize: socialIconSize,
                                    symbolSize: socialSymbolSize
                                )
                                socialIcon(
                                    imageName: "instagram",
                                    urlString: "https://www.instagram.com/ocolegiopaulofreire/",
                                    iconSize: socialIconSize,
                                    symbolSize: socialSymbolSize
                                )
                            }
                            .padding(.top, socialTopPadding)
                            .padding(.bottom, 18)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: max(proxy.size.height - footerHeight, 0), alignment: .top)
                    }

                    ZStack {
                        AppPalette.primaryNavy

                        Text("© 2026 Colegio Professor Paulo Freire - Todos os direitos reservados")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.78))
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                            .allowsTightening(true)
                            .padding(.horizontal, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: footerHeight)
                }

                if showStudentAreaLoading {
                    StudentAreaLoadingOverlay()
                }
            }
        }
        .sheet(isPresented: $showWebView) {
            if let url = selectedURL {
                NavigationStack {
                    WebScreen(url: url)
                        .navigationTitle("Colegio Professor Paulo Freire")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Fechar") {
                                    showWebView = false
                                }
                            }
                        }
                }
            }
        }
        .fullScreenCover(isPresented: $showStudentArea) {
            StudentAreaFullScreenView(
                url: URL(string: "https://cppaulofreire.com.br/aluno/")!
            )
        }
    }

    @ViewBuilder
    private func socialIcon(imageName: String, urlString: String, iconSize: CGFloat, symbolSize: CGFloat) -> some View {
        Button {
            openExternalLink(urlString)
        } label: {
            ZStack {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(AppPalette.primaryNavy)
                    .scaledToFit()
                    .frame(width: symbolSize, height: symbolSize)
            }
            .frame(width: iconSize, height: iconSize)
        }
        .buttonStyle(.plain)
    }

    private func openLink(_ urlString: String) {
        selectedURL = URL(string: urlString)
        showWebView = selectedURL != nil
    }

    private func openStudentArea() {
        showStudentAreaLoading = true

        Task {
            try? await Task.sleep(for: .milliseconds(650))
            guard !Task.isCancelled else { return }
            showStudentAreaLoading = false
            showStudentArea = true
        }
    }

    private func openExternalLink(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        openURL(url)
    }
}

private struct StudentAreaLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.white.opacity(0.76)
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
            .padding(.horizontal, 28)
        }
    }
}

private struct AnimatedBackgroundCircles: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Circle()
                    .fill(AppPalette.paleBlue.opacity(0.95))
                    .frame(width: 128, height: 128)
                    .blur(radius: 6)
                    .offset(
                        x: animate ? width * 0.34 : width * 0.18,
                        y: animate ? -height * 0.32 : -height * 0.18
                    )
                    .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)

                Circle()
                    .fill(AppPalette.softGray.opacity(0.92))
                    .frame(width: 112, height: 112)
                    .blur(radius: 5)
                    .offset(
                        x: animate ? -width * 0.32 : -width * 0.16,
                        y: animate ? height * 0.18 : height * 0.3
                    )
                    .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: animate)

                Circle()
                    .fill(AppPalette.paleBlue.opacity(0.86))
                    .frame(width: 154, height: 154)
                    .blur(radius: 6)
                    .offset(
                        x: animate ? width * 0.22 : width * 0.38,
                        y: animate ? height * 0.36 : height * 0.48
                    )
                    .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)

                Circle()
                    .fill(AppPalette.softGray.opacity(0.9))
                    .frame(width: 88, height: 88)
                    .blur(radius: 4)
                    .offset(
                        x: animate ? -width * 0.22 : -width * 0.36,
                        y: animate ? -height * 0.38 : -height * 0.24
                    )
                    .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    ContentView()
}
