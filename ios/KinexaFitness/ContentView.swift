import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            MainTabView()
                .background(KinexaTheme.background.ignoresSafeArea())

            if showSplash {
                SplashView {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                        showSplash = false
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .scale(scale: 1.05).combined(with: .opacity)
                ))
                .zIndex(1)
            }
        }
    }
}
