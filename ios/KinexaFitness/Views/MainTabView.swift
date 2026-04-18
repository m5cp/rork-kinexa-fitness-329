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
    @State private var selectedTab: AppTab = .home
    @State private var homePath = NavigationPath()
    @State private var workoutsPath = NavigationPath()
    @State private var nutritionPath = NavigationPath()
    @State private var progressPath = NavigationPath()
    @State private var profilePath = NavigationPath()
    @State private var showCoachChat: Bool = false

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

            coachFloatingButton
                .padding(.trailing, 16)
                .padding(.bottom, 88)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .zIndex(101)
        }
        .background(KinexaTheme.background.ignoresSafeArea())
        .instantRecapOverlay(recap: Binding(
            get: { vm.activeRecap },
            set: { vm.activeRecap = $0 }
        ))
        .sheet(isPresented: $showCoachChat) {
            CoachChatView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
    }

    @ViewBuilder
    private var coachFloatingButton: some View {
        if #available(iOS 26.0, *) {
            Button {
                showCoachChat = true
            } label: {
                Image(systemName: "sparkles")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
            }
            .glassEffect(.regular.tint(KinexaTheme.accent).interactive(), in: .circle)
            .shadow(color: KinexaTheme.accent.opacity(0.35), radius: 12, y: 6)
            .buttonStyle(PressScaleButtonStyle())
            .accessibilityLabel("Coach chat")
            .sensoryFeedback(.impact(weight: .medium), trigger: showCoachChat)
        } else {
            Button {
                showCoachChat = true
            } label: {
                ZStack {
                    Circle()
                        .fill(KinexaTheme.heroGradient)
                        .frame(width: 56, height: 56)
                        .shadow(color: KinexaTheme.accent.opacity(0.35), radius: 12, y: 6)
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                    Image(systemName: "sparkles")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(PressScaleButtonStyle())
            .accessibilityLabel("Coach chat")
            .sensoryFeedback(.impact(weight: .medium), trigger: showCoachChat)
        }
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
            .foregroundStyle(isSelected ? KinexaTheme.accent : KinexaTheme.tertiaryText)
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
                .fill(KinexaTheme.accent.opacity(0.14))
        } else {
            Capsule()
                .fill(KinexaTheme.accent.opacity(0.12))
        }
    }
}

private struct TabBarGlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: .capsule)
                .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
        } else {
            content
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Capsule().stroke(KinexaTheme.border.opacity(0.6), lineWidth: 0.5)
                        }
                }
                .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
        }
    }
}
