import SwiftUI
import UIKit

struct SupportSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let supportEmail: String = "contact@m5cairo.com"

    @State private var copied: Bool = false
    @State private var copyTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                KynexaTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        header

                        emailCard

                        sendEmailButton

                        helperText

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KynexaTheme.accent)
                }
            }
        }
        .sensoryFeedback(.success, trigger: copyTrigger)
    }

    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [KynexaTheme.accent, KynexaTheme.accent.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .shadow(color: KynexaTheme.accent.opacity(0.35), radius: 18, y: 8)

                Image(systemName: "envelope.fill")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text("Contact Support")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                Text("We're here to help. Reach out anytime.")
                    .font(.subheadline)
                    .foregroundStyle(KynexaTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 12)
    }

    private var emailCard: some View {
        Button {
            UIPasteboard.general.string = supportEmail
            copied = true
            copyTrigger.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                copied = false
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "at")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KynexaTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(KynexaTheme.accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Email")
                        .font(.caption.weight(.heavy))
                        .tracking(1.0)
                        .foregroundStyle(KynexaTheme.tertiaryText)
                    Text(supportEmail)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KynexaTheme.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 0)

                Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(copied ? KynexaTheme.success : KynexaTheme.tertiaryText)
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(16)
            .background(KynexaTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .elevatedCardShadow()
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(KynexaTheme.border)
            }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .top) {
            if copied {
                Text("Copied")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.6)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(KynexaTheme.success)
                    .clipShape(Capsule())
                    .offset(y: -14)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: copied)
    }

    private var sendEmailButton: some View {
        Button {
            if let url = URL(string: "mailto:\(supportEmail)?subject=Kynexa%20Fit%20Support"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "paperplane.fill")
                    .font(.subheadline.weight(.bold))
                Text("Send Email")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(KynexaTheme.accent)
            .clipShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var helperText: some View {
        VStack(spacing: 6) {
            Text("Average response time: within 24 hours")
                .font(.caption)
                .foregroundStyle(KynexaTheme.tertiaryText)
            Text("Include a brief description of your issue and your device model to help us resolve it faster.")
                .font(.caption2)
                .foregroundStyle(KynexaTheme.tertiaryText.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 12)
    }
}

#Preview {
    SupportSheet()
}
