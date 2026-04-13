import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(StoreViewModel.self) private var store

    @AppStorage("ptGoal") private var ptGoalRaw = ""
    @AppStorage("planWeeks") private var planWeeks = 4
    @AppStorage("daysPerWeek") private var daysPerWeek = 3
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 6
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("profileDisplayName") private var profileDisplayName = ""

    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? .now
    @State private var showResetAlert = false
    @State private var showResetPlanAlert = false
    @State private var resetPlanTrigger = false
    @State private var resetAllTrigger = false
    @State private var showAvatarPicker = false
    @State private var showUpgrade = false
    @State private var showTokenStore = false
    @State private var restoreTrigger = false
    @State private var imageManager = ProfileImageManager()
    @State private var isEditingName: Bool = false
    @State private var devTapCount: Int = 0
    @State private var showDevMenu: Bool = false
    @State private var bypassToggleTrigger: Bool = false
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    profileHeader
                    subscriptionSection
                    currentGoalSection
                    notificationsSection
                    appControlsSection
                    supportSection
                    legalSection
                    footer
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            reminderTime = Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? .now
        }
        .alert("Reset weekly plan?", isPresented: $showResetPlanAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset Plan", role: .destructive) {
                vm.generateWeeklyPlan()
                resetPlanTrigger.toggle()
            }
        } message: {
            Text("This will generate a new weekly plan, replacing the current one.")
        }
        .alert("Reset all data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                vm.resetAllData()
                imageManager.removeImage()
                profileDisplayName = ""
                resetAllTrigger.toggle()
            }
        } message: {
            Text("This will erase all saved workouts, completed records, unit PT plans, and step history from this device.")
        }
        .sheet(isPresented: $showAvatarPicker) {
            avatarPickerSheet
        }
        .onChange(of: imageManager.selectedItem) { _, newItem in
            Task {
                await imageManager.handlePickerItem(newItem)
                imageManager.selectedItem = nil
            }
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: 20) {
            Button {
                showAvatarPicker = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    avatarImage
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())

                    Circle()
                        .fill(KinexaTheme.card)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(KinexaTheme.accent)
                        }
                        .overlay {
                            Circle().stroke(KinexaTheme.background, lineWidth: 2)
                        }
                }
            }
            .buttonStyle(.plain)

            VStack(spacing: 8) {
                if isEditingName {
                    TextField("User", text: $profileDisplayName)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .focused($nameFieldFocused)
                        .submitLabel(.done)
                        .onSubmit { isEditingName = false }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(KinexaTheme.accent.opacity(0.3))
                        }
                        .frame(maxWidth: 240)
                } else {
                    Button {
                        isEditingName = true
                        nameFieldFocused = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(profileDisplayName.isEmpty ? "User" : profileDisplayName)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(KinexaTheme.primaryText)
                            Image(systemName: "pencil")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Text(profileSubtitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(KinexaTheme.accent)
            }

            HStack(spacing: 0) {
                statCell(value: "\(vm.totalWorkoutsCompleted)", label: "Workouts")
                dividerLine
                statCell(value: "\(vm.streak)", label: "Streak")
                dividerLine
                statCell(value: "\(vm.totalCardioMinutesThisWeek)", label: "Cardio Min")
            }
            .padding(.vertical, 14)
            .background(KinexaTheme.cardSoft)
            .clipShape(.rect(cornerRadius: 14))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(KinexaTheme.border)
        }
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let image = imageManager.profileImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let avatarIdx = imageManager.selectedAvatarIndex,
                  avatarIdx < ProfileImageManager.avatarSymbols.count {
            Circle()
                .fill(KinexaTheme.accent.opacity(0.15))
                .overlay {
                    Image(systemName: ProfileImageManager.avatarSymbols[avatarIdx])
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(KinexaTheme.accent)
                }
        } else {
            Circle()
                .fill(KinexaTheme.accent.opacity(0.12))
                .overlay {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(KinexaTheme.accent)
                }
        }
    }

    private var profileSubtitle: String {
        if let goal = PTGoal(rawValue: ptGoalRaw) {
            return "\(goal.rawValue) · \(planWeeks)-Week Plan"
        }
        return "No goal set · Open Plan My Training"
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(KinexaTheme.border)
            .frame(width: 1, height: 28)
    }

    // MARK: - Subscription Management

    private var subscriptionSection: some View {
        settingsSection(title: "SUBSCRIPTION", icon: "crown") {
            if store.isPremium {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.heroAmber)
                        .frame(width: 24)
                    Text("Kinexa Pro Active")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Spacer()
                    Text("PRO")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(KinexaTheme.heroAmber)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(KinexaTheme.heroAmber.opacity(0.15))
                        .clipShape(Capsule())
                }
                .frame(minHeight: 48)
            } else {
                Button {
                    showUpgrade = true
                } label: {
                    settingsRow(icon: "crown.fill", title: "Upgrade to Pro", color: KinexaTheme.heroAmber, showChevron: true)
                }
            }

            sectionDivider

            Button {
                showTokenStore = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(hex: "#8B5CF6"))
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Tokens")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(KinexaTheme.primaryText)
                        let tracker = AIUsageTracker.shared
                        Text("\(tracker.totalRemaining) scan\(tracker.totalRemaining == 1 ? "" : "s") remaining · \(tracker.bonusTokens) bonus token\(tracker.bonusTokens == 1 ? "" : "s")")
                            .font(.caption2)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("\(AIUsageTracker.shared.totalRemaining)")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Color(hex: "#8B5CF6"))
                            .contentTransition(.numericText())
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }
                .frame(minHeight: 48)
            }

            sectionDivider

            Button {
                restoreTrigger.toggle()
                Task { await store.restore() }
            } label: {
                settingsRow(icon: "arrow.triangle.2.circlepath", title: "Restore Purchases", color: KinexaTheme.accent)
            }
            .sensoryFeedback(.impact(weight: .light), trigger: restoreTrigger)

            sectionDivider

            Button {
                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                    UIApplication.shared.open(url)
                }
            } label: {
                settingsRow(icon: "creditcard", title: "Manage Subscription", color: KinexaTheme.slateAccent, showChevron: true)
            }
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
        }
        .sheet(isPresented: $showTokenStore) {
            TokenStoreView()
        }
    }

    // MARK: - Current Goal

    private var currentGoalSection: some View {
        settingsSection(title: "CURRENT GOAL", icon: "target") {
            if let goal = PTGoal(rawValue: ptGoalRaw) {
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        Image(systemName: goal.icon)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [KinexaTheme.accent, KinexaTheme.accent2],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(goal.rawValue)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KinexaTheme.primaryText)
                            Text(goal.subtitle)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)

                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("\(planWeeks)")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(KinexaTheme.accent)
                            Text("Weeks")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(KinexaTheme.border)
                            .frame(width: 1, height: 28)

                        VStack(spacing: 2) {
                            Text("\(vm.currentPlan?.currentWeek ?? 1)")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(KinexaTheme.accent)
                            Text("Current")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(KinexaTheme.border)
                            .frame(width: 1, height: 28)

                        VStack(spacing: 2) {
                            Text("\(daysPerWeek)")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(KinexaTheme.accent)
                            Text("Days/Wk")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(12)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.vertical, 4)
            } else {
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        Image(systemName: "target")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                            .frame(width: 44, height: 44)
                            .background(KinexaTheme.cardSoft)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 3) {
                            Text("No Goal Set")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KinexaTheme.primaryText)
                            Text("Open Plan My Training to set your training goal and plan duration")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        settingsSection(title: "NOTIFICATIONS", icon: "bell.badge") {
            HStack {
                Image(systemName: "bell.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.accent)
                    .frame(width: 24)
                Text("Daily Reminder")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
                Toggle("", isOn: $dailyReminderEnabled)
                    .labelsHidden()
                    .tint(KinexaTheme.accent)
            }
            .frame(minHeight: 44)
            .onChange(of: dailyReminderEnabled) { _, newValue in
                Task {
                    if newValue {
                        let granted = await NotificationManager.requestPermission()
                        if granted {
                            await NotificationManager.scheduleDailyReminder(at: reminderTime)
                        }
                    } else {
                        NotificationManager.removeDailyReminder()
                    }
                }
            }

            if dailyReminderEnabled {
                sectionDivider
                HStack {
                    Image(systemName: "clock")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.accent)
                        .frame(width: 24)
                    Text("Time")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Spacer()
                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorScheme(.dark)
                }
                .frame(minHeight: 44)
                .onChange(of: reminderTime) { _, newValue in
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                    reminderHour = comps.hour ?? 6
                    reminderMinute = comps.minute ?? 0
                    Task {
                        if dailyReminderEnabled {
                            await NotificationManager.scheduleDailyReminder(at: newValue)
                        }
                    }
                }
            }
        }
    }

    // MARK: - App Controls

    private var appControlsSection: some View {
        settingsSection(title: "APP", icon: "gearshape") {
            NavigationLink {
                StyleEditorView()
            } label: {
                settingsRow(icon: "paintpalette.fill", title: "Style Editor", color: KinexaTheme.accent, showChevron: true)
            }

            sectionDivider

            Button {
                showResetPlanAlert = true
            } label: {
                settingsRow(icon: "arrow.clockwise", title: "Reset Weekly Plan", color: KinexaTheme.warning)
            }
            .sensoryFeedback(.warning, trigger: resetPlanTrigger)

            sectionDivider

            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                settingsRow(icon: "trash", title: "Reset All Data", color: KinexaTheme.danger)
            }
            .sensoryFeedback(.warning, trigger: resetAllTrigger)

        }
    }

    // MARK: - Support & Partners

    @State private var showNutritionPartner: Bool = false

    private var supportSection: some View {
        settingsSection(title: "SUPPORT & PARTNERS", icon: "person.2") {
            Button {
                showNutritionPartner = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#059669"), Color(hex: "#10B981")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nutrition Partner")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text("Personalized nutrition consultations")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .frame(minHeight: 48)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            sectionDivider

            Button {
                if let url = URL(string: "mailto:support@kinexafit.com") {
                    UIApplication.shared.open(url)
                }
            } label: {
                settingsRow(icon: "questionmark.circle", title: "Contact Support", color: KinexaTheme.accent, showChevron: true)
            }
        }
        .sheet(isPresented: $showNutritionPartner) {
            NutritionPartnerView()
        }
    }

    // MARK: - Legal

    private var legalSection: some View {
        settingsSection(title: "LEGAL", icon: "doc.text") {
            NavigationLink {
                LegalTextView(title: "Privacy Policy", content: LegalContent.privacyPolicy)
            } label: {
                settingsRow(icon: "lock.shield", title: "Privacy Policy", color: KinexaTheme.accent, showChevron: true)
            }
            .accessibilityHint("View the app privacy policy")

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Terms of Use", content: LegalContent.termsOfUse)
            } label: {
                settingsRow(icon: "doc.plaintext", title: "Terms of Use", color: KinexaTheme.accent, showChevron: true)
            }
            .accessibilityHint("View the terms of use")

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Disclaimer", content: LegalContent.disclaimer)
            } label: {
                settingsRow(icon: "exclamationmark.triangle", title: "Disclaimer", color: KinexaTheme.warning, showChevron: true)
            }
            .accessibilityHint("View the fitness and nutrition disclaimer")

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Risks", content: LegalContent.risks)
            } label: {
                settingsRow(icon: "heart.text.square", title: "Risks", color: KinexaTheme.danger, showChevron: true)
            }
            .accessibilityHint("View exercise risk information")

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Accessibility", content: LegalContent.accessibilityStatement)
            } label: {
                settingsRow(icon: "accessibility", title: "Accessibility", color: KinexaTheme.accent, showChevron: true)
            }
            .accessibilityHint("View the accessibility statement")

            sectionDivider

            NavigationLink {
                LegalTextView(title: "EULA", content: LegalContent.eula)
            } label: {
                settingsRow(icon: "doc.badge.gearshape", title: "EULA", color: KinexaTheme.slateAccent, showChevron: true)
            }
            .accessibilityHint("View the end user license agreement")
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 6) {
            Text("KINEXA FIT")
                .font(.caption.weight(.heavy))
                .tracking(2.0)
                .foregroundStyle(KinexaTheme.tertiaryText)
            Text("Rise Before The Sun")
                .font(.caption2.weight(.medium))
                .foregroundStyle(KinexaTheme.tertiaryText.opacity(0.6))
            Text("Version 1.0.0")
                .font(.caption2)
                .foregroundStyle(KinexaTheme.tertiaryText.opacity(0.4))
                .onTapGesture {
                    devTapCount += 1
                    if devTapCount >= 5 {
                        devTapCount = 0
                        showDevMenu = true
                    }
                }

            #if DEBUG
            if store.testBypassEnabled {
                HStack(spacing: 4) {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 8))
                    Text("TEST BYPASS ACTIVE")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(0.5)
                }
                .foregroundStyle(KinexaTheme.warning)
                .padding(.top, 4)
            }
            #endif
        }
        .padding(.top, 8)
        .sheet(isPresented: $showDevMenu) {
            devMenuSheet
        }
    }

    #if DEBUG
    private var devMenuSheet: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "hammer.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(KinexaTheme.warning)
                        Text("Developer Menu")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text("These options are only available in debug builds.")
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Image(systemName: "crown.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KinexaTheme.heroAmber)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Bypass Paywall")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(KinexaTheme.primaryText)
                                Text("Unlock all Pro features for testing")
                                    .font(.caption2)
                                    .foregroundStyle(KinexaTheme.tertiaryText)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { store.testBypassEnabled },
                                set: { store.testBypassEnabled = $0 }
                            ))
                            .labelsHidden()
                            .tint(KinexaTheme.heroAmber)
                        }
                        .frame(minHeight: 56)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(KinexaTheme.border)
                    }

                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(store.isPremium ? KinexaTheme.success : KinexaTheme.danger)
                                .frame(width: 8, height: 8)
                            Text(store.isPremium ? "Premium Active" : "Free Tier")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(KinexaTheme.secondaryText)
                        }
                        Text("RevenueCat entitlement: \(store.testBypassEnabled ? "bypassed" : "checking server")")
                            .font(.caption2)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showDevMenu = false }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    #else
    private var devMenuSheet: some View {
        EmptyView()
    }
    #endif

    // MARK: - Reusable Components

    private func settingsSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text(title)
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 10)

            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(KinexaTheme.border)
            }
        }
    }

    private var sectionDivider: some View {
        Divider()
            .overlay(KinexaTheme.border)
            .padding(.leading, 36)
    }

    private func settingsRow(icon: String, title: String, color: Color, showChevron: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 24)
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(KinexaTheme.primaryText)
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }

    // MARK: - Avatar Picker Sheet

    private var avatarPickerSheet: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Text("Choose Profile Image")
                                .font(.headline)
                                .foregroundStyle(KinexaTheme.primaryText)
                            Text("Upload a photo or pick an avatar")
                                .font(.subheadline)
                                .foregroundStyle(KinexaTheme.secondaryText)
                        }

                        PhotosPicker(selection: Binding(
                            get: { imageManager.selectedItem },
                            set: { imageManager.selectedItem = $0 }
                        ), matching: .images) {
                            HStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.subheadline.weight(.semibold))
                                Text("Choose from Library")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(height: 52)
                            .frame(maxWidth: .infinity)
                            .background(KinexaTheme.heroGradient)
                            .clipShape(.rect(cornerRadius: 16))
                        }
                        .buttonStyle(PressScaleButtonStyle())

                        VStack(alignment: .leading, spacing: 14) {
                            Text("AVATARS")
                                .font(.caption.weight(.bold))
                                .tracking(1.0)
                                .foregroundStyle(KinexaTheme.tertiaryText)

                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(Array(ProfileImageManager.avatarOptions.enumerated()), id: \.offset) { index, avatar in
                                    let isSelected = imageManager.selectedAvatarIndex == index && imageManager.profileImage == nil
                                    Button {
                                        imageManager.selectAvatar(index)
                                        showAvatarPicker = false
                                    } label: {
                                        VStack(spacing: 6) {
                                            Circle()
                                                .fill(isSelected ? KinexaTheme.accent.opacity(0.2) : KinexaTheme.cardSoft)
                                                .frame(width: 56, height: 56)
                                                .overlay {
                                                    Image(systemName: avatar.symbol)
                                                        .font(.title3.weight(.bold))
                                                        .foregroundStyle(isSelected ? KinexaTheme.accent : KinexaTheme.secondaryText)
                                                }
                                                .overlay {
                                                    Circle()
                                                        .stroke(isSelected ? KinexaTheme.accent : KinexaTheme.border, lineWidth: isSelected ? 2 : 1)
                                                }
                                            Text(avatar.label)
                                                .font(.caption2.weight(.medium))
                                                .foregroundStyle(isSelected ? KinexaTheme.accent : KinexaTheme.tertiaryText)
                                                .lineLimit(1)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if imageManager.profileImage != nil || imageManager.selectedAvatarIndex != nil {
                            Button {
                                imageManager.removeImage()
                                showAvatarPicker = false
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle")
                                        .font(.subheadline.weight(.semibold))
                                    Text("Remove Image")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .foregroundStyle(KinexaTheme.danger)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(KinexaTheme.danger.opacity(0.1))
                                .clipShape(.rect(cornerRadius: 14))
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        }
                    }
                    .padding(20)
                    .adaptiveContainer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showAvatarPicker = false }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
