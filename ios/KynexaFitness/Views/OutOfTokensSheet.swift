import SwiftUI

struct OutOfTokensSheet: View {
    let isPremium: Bool
    var onBuyTokens: () -> Void
    var onSubscribe: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#8B5CF6").opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: "sparkles")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color(hex: "#8B5CF6"))
            }
            .padding(.top, 8)

            VStack(spacing: 8) {
                Text(AIUsageTracker.shared.limitReachedTitle)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                Text(AIUsageTracker.shared.limitReachedMessage)
                    .font(.subheadline)
                    .foregroundStyle(KynexaTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 10) {
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onBuyTokens() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.subheadline.weight(.bold))
                        Text("Buy Tokens")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#8B5CF6"), Color(hex: "#6366F1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 14))
                }
                .buttonStyle(PressScaleButtonStyle())

                if !isPremium {
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onSubscribe() }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.subheadline.weight(.bold))
                            Text("Subscribe")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [KynexaTheme.accent, Color(hex: "#2E7D52")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }

                Button("Not now") { dismiss() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KynexaTheme.secondaryText)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 4)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 20)
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.visible)
    }
}
