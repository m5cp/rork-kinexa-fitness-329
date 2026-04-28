import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var vm
    @AppStorage("hasSeenSplash") private var hasSeenSplash: Bool = false
    @AppStorage("hasConfirmedAge") private var hasConfirmedAge: Bool = false
    @State private var showSplash: Bool

    init() {
        _showSplash = State(initialValue: !UserDefaults.standard.bool(forKey: "hasSeenSplash"))
    }

    var body: some View {
        ZStack {
            MainTabView()
                .background(KynexaTheme.background.ignoresSafeArea())

            if showSplash {
                SplashView {
                    hasSeenSplash = true
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                        showSplash = false
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .scale(scale: 1.05).combined(with: .opacity)
                ))
                .zIndex(2)
            }

            if !showSplash && !hasConfirmedAge {
                AgeGateView {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        hasConfirmedAge = true
                    }
                }
                .transition(.opacity)
                .zIndex(3)
            }
        }
    }
}
