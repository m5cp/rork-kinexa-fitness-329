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
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
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

                coachFloatingButton
                    .padding(.trailing, 16)
                    .padding(.bottom, 12)
                    .zIndex(100)
            }

            customTabBar
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

    private var coachFloatingButton: some View {
        Button {
            showCoachChat = true
        } label: {
            ZStack {
                Circle()
                    .fill(KinexaTheme.heroGradient)
                    .frame(width: 54, height: 54)
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

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Button {
                    if selectedTab == tab {
                        switch tab {
                        case .home: homePath = NavigationPath()
                        case .workouts: workoutsPath = NavigationPath()
                        case .nutrition: nutritionPath = NavigationPath()
                        case .progress: progressPath = NavigationPath()
                        case .profile: profilePath = NavigationPath()
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTab = tab
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: horizontalSizeClass == .regular ? 22 : 18, weight: selectedTab == tab ? .bold : .regular))
                            .symbolEffect(.bounce, value: selectedTab == tab)
                        Text(tab.title)
                            .font(.system(size: horizontalSizeClass == .regular ? 12 : 10, weight: selectedTab == tab ? .bold : .medium))
                    }
                    .foregroundStyle(selectedTab == tab ? KinexaTheme.accent : KinexaTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .padding(.top, 10)
                    .padding(.bottom, 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            }
        }
        .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
        .frame(maxWidth: .infinity)
        .safeAreaPadding(.bottom)
        .background {
            KinexaTheme.background
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(KinexaTheme.border)
                        .frame(height: 0.5)
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }
}
