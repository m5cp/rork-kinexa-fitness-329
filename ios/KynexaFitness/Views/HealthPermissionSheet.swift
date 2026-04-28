import SwiftUI
import HealthKit

struct HealthPermissionSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onConnect: () async -> Bool
    var onConnected: (Bool) -> Void = { _ in }

    @State private var isRequesting: Bool = false

    private let red = Color(hex: "#EF4444")

    var body: some View {
        ZStack {
            KynexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header

                    VStack(spacing: 12) {
                        infoRow(
                            icon: "arrow.down.circle.fill",
                            tint: red,
                            title: "We read",
                            body: "Step count, active energy, and workout history — only to display your daily activity inside Kynexa."
                        )
                        infoRow(
                            icon: "arrow.up.circle.fill",
                            tint: KynexaTheme.accent,
                            title: "We write",
                            body: "The workouts you complete in Kynexa, so they appear in your Apple Health activity rings and workout history."
                        )
                        infoRow(
                            icon: "lock.shield.fill",
                            tint: KynexaTheme.success,
                            title: "Your data stays private",
                            body: "Health data never leaves your device. We don't upload it, sell it, share it, or use it for advertising or AI processing."
                        )
                        infoRow(
                            icon: "gearshape.fill",
                            tint: KynexaTheme.slateAccent,
                            title: "You're always in control",
                            body: "You can change or revoke access at any time in Settings → Privacy & Security → Health → Kynexa Fitness."
                        )
                    }

                    VStack(spacing: 10) {
                        Button {
                            Task { await connect() }
                        } label: {
                            HStack(spacing: 8) {
                                if isRequesting {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "heart.fill")
                                        .font(.subheadline.weight(.bold))
                                }
                                Text(isRequesting ? "Connecting…" : "Connect Apple Health")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(height: 52)
                            .frame(maxWidth: .infinity)
                            .background(red)
                            .clipShape(.rect(cornerRadius: 16))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                        .disabled(isRequesting)

                        Button {
                            onConnected(false)
                            dismiss()
                        } label: {
                            Text("Not Now")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KynexaTheme.secondaryText)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(isRequesting)
                    }

                    Text("Apple's standard permission dialog will appear next so you can choose exactly which data types to share.")
                        .font(.caption2)
                        .foregroundStyle(KynexaTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 32)
                .adaptiveContainer()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(red.opacity(0.15))
                    .frame(width: 76, height: 76)
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(red)
            }

            Text("Connect Apple Health")
                .font(.title2.weight(.bold))
                .foregroundStyle(KynexaTheme.primaryText)

            Text("Sync your activity and workouts so everything stays in one place.")
                .font(.subheadline)
                .foregroundStyle(KynexaTheme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func infoRow(icon: String, tint: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(tint.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KynexaTheme.primaryText)
                Text(body)
                    .font(.caption)
                    .foregroundStyle(KynexaTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KynexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(KynexaTheme.border)
        }
    }

    private func connect() async {
        isRequesting = true
        let granted = await onConnect()
        isRequesting = false
        onConnected(granted)
        dismiss()
    }
}

struct HealthDataDisclosureSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let red = Color(hex: "#EF4444")

    var body: some View {
        NavigationStack {
            ZStack {
                KynexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header

                        disclosureCard(
                            icon: "arrow.down.circle.fill",
                            tint: red,
                            title: "Data we read from Apple Health",
                            body: "• Step count\n• Active energy burned\n• Workout sessions\n\nThese values are read only to display your daily activity inside Kynexa Fitness. They are not stored on our servers."
                        )

                        disclosureCard(
                            icon: "arrow.up.circle.fill",
                            tint: KynexaTheme.accent,
                            title: "Data we write to Apple Health",
                            body: "• Workouts you complete inside Kynexa\n\nWriting workouts to Health lets them count toward your activity rings and appear in the Health app's workout history."
                        )

                        disclosureCard(
                            icon: "lock.shield.fill",
                            tint: KynexaTheme.success,
                            title: "How we protect your Health data",
                            body: "• Health data never leaves your device.\n• We do not upload it to any server, cloud, or backup we control.\n• We never sell, share, or transfer it to third parties.\n• We never use it for advertising or marketing.\n• We never use Health data for any purpose other than what is described here."
                        )

                        disclosureCard(
                            icon: "sparkles",
                            tint: Color(hex: "#6366F1"),
                            title: "AI features and Health data",
                            body: "AI-powered features in Kynexa never receive your Apple Health data. Step counts shown elsewhere in the app come from your device's built-in pedometer (Core Motion), not from Apple Health."
                        )

                        disclosureCard(
                            icon: "gearshape.fill",
                            tint: KynexaTheme.slateAccent,
                            title: "You're always in control",
                            body: "You can review or revoke each individual data type at any time in:\n\nSettings → Privacy & Security → Health → Kynexa Fitness\n\nIf you revoke access, the rest of the app continues to work normally."
                        )

                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.subheadline.weight(.bold))
                                Text("Open Settings")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(red)
                            .clipShape(.rect(cornerRadius: 14))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                    .adaptiveContainer()
                }
            }
            .navigationTitle("How we use Health data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KynexaTheme.primaryText)
                }
            }
            .toolbarBackground(KynexaTheme.background, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(red.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "heart.text.square.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(red)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Apple Health")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                Text("Required disclosures for Health data use.")
                    .font(.caption)
                    .foregroundStyle(KynexaTheme.secondaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, 4)
    }

    private func disclosureCard(icon: String, tint: Color, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(tint)
                    .frame(width: 28, height: 28)
                    .background(tint.opacity(0.15))
                    .clipShape(.rect(cornerRadius: 8))
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
            }
            Text(body)
                .font(.caption)
                .foregroundStyle(KynexaTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KynexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(KynexaTheme.border)
        }
    }
}
