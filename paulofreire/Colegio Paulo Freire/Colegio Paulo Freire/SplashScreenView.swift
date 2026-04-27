import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            AppPalette.background
                .ignoresSafeArea()

            Image("launch_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
        }
    }
}
