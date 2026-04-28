import SwiftUI

nonisolated enum AppTab: Int, CaseIterable, Sendable {
    case home = 0
    case workouts = 1
    case nutrition = 2
    case progress = 3
    case profile = 4

    var title: String {
        switch self {
        case .home: return "Home"
        case .workouts: return "Workouts"
        case .nutrition: return "Nutrition"
        case .progress: return "Progress"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .workouts: return "dumbbell.fill"
        case .nutrition: return "fork.knife"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(AppViewModel.self) private var vm
    @AppStorage("pendingInitialTab") private var pendingInitialTab: Int = AppTab.home.rawValue
    @State private var selectedTab: AppTab = .home
    @State private var homePath = NavigationPath()
    @State private var workoutsPath = NavigationPath()
    @State private var nutritionPath = NavigationPath()
    @State private var progressPath = NavigationPath()
    @State private var profilePath = NavigationPath()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                NavigationStack(path: $homePath) {
                    HomeView()
                }
                .opacity(selectedTab == .home ? 1 : 0)
                .zIndex(selectedTab == .home ? 1 : 0)

                NavigationStack(path: $workoutsPath) {
                    WorkoutsTabView()
                }
                .opacity(selectedTab == .workouts ? 1 : 0)
                .zIndex(selectedTab == .workouts ? 1 : 0)

                NavigationStack(path: $nutritionPath) {
                    NutritionTabView()
                }
                .opacity(selectedTab == .nutrition ? 1 : 0)
                .zIndex(selectedTab == .nutrition ? 1 : 0)

                NavigationStack(path: $progressPath) {
                    ProgressViewScreen()
                }
                .opacity(selectedTab == .progress ? 1 : 0)
                .zIndex(selectedTab == .progress ? 1 : 0)

                NavigationStack(path: $profilePath) {
                    ProfileView()
                }
                .opacity(selectedTab == .profile ? 1 : 0)
                .zIndex(selectedTab == .profile ? 1 : 0)
            }
            .safeAreaPadding(.bottom, 72)

            customTabBar
                .padding(.horizontal, 12)
                .padding(.bottom, 4)
                .zIndex(100)
        }
        .background(KynexaTheme.background.ignoresSafeArea())
        .instantRecapOverlay(recap: Binding(
            get: { vm.activeRecap },
            set: { vm.activeRecap = $0 }
        ))
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var customTabBar: some View {
        HStack(spacing: 2) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
        .modifier(TabBarGlassBackground())
    }

    @ViewBuilder
    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        Button {
            if isSelected {
                switch tab {
                case .home: homePath = NavigationPath()
                case .workouts: workoutsPath = NavigationPath()
                case .nutrition: nutritionPath = NavigationPath()
                case .progress: progressPath = NavigationPath()
                case .profile: profilePath = NavigationPath()
                }
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    selectedTab = tab
                }
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                    .symbolEffect(.bounce, value: isSelected)
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .foregroundStyle(isSelected ? KynexaTheme.accent : KynexaTheme.tertiaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                if isSelected {
                    TabSelectionPill()
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct TabSelectionPill: View {
    var body: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .fill(KynexaTheme.accent.opacity(0.14))
        } else {
            Capsule()
                .fill(KynexaTheme.accent.opacity(0.12))
        }
    }
}

private struct TabBarGlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial.opacity(0.55))
                        .overlay {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.22),
                                            Color.white.opacity(0.04)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .blendMode(.plusLighter)
                        }
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.55),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.8
                                )
                        }
                }
                .shadow(color: .black.opacity(0.10), radius: 20, y: 10)
        } else {
            content
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial.opacity(0.6))
                        .overlay {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.18),
                                            Color.white.opacity(0.02)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.5),
                                            Color.white.opacity(0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.7
                                )
                        }
                }
                .shadow(color: .black.opacity(0.10), radius: 20, y: 10)
        }
    }
}
