//
//  ColegioProfessorPauloFreireApp.swift
//  Colegio Professor Paulo Freire
//
//  Created by Keven Matheus on 14/04/26.
//

import SwiftUI

@main
struct ColegioProfessorPauloFreireApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

private struct RootView: View {
    @State private var showLaunchCover = true

    var body: some View {
        ZStack {
            ContentView()

            if showLaunchCover {
                SplashScreenView()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(900))
            withAnimation(.easeOut(duration: 0.2)) {
                showLaunchCover = false
            }
        }
    }
}
