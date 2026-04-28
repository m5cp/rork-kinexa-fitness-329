import SwiftUI
import AppIntents
import RevenueCat

@main
struct KynexaFitnessApp: App {
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = AppViewModel()
    @State private var store = StoreViewModel()
    @State private var nutritionVM = NutritionViewModel()
    @State private var ringsVM = ReflectionRingsViewModel()

    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif
        KynexaFitnessShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(viewModel)
                .environment(store)
                .environment(nutritionVM)
                .environment(ringsVM)
                .preferredColorScheme(AppearanceMode(rawValue: appearanceModeRaw)?.colorScheme)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        if viewModel.pedometer.hasOptedIn {
                            viewModel.pedometer.refreshTodaySteps()
                            Task {
                                try? await Task.sleep(for: .milliseconds(300))
                                viewModel.syncTodaySteps()
                            }
                        }
                        viewModel.syncWidgetData()
                    }
                }
        }
    }
}
