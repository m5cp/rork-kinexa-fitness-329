import SwiftUI

struct MilestoneCelebrationView: View {
    let milestone: Milestone
    let onDismiss: () -> Void

    @State private var animateIn: Bool = false
    @State private var pulseIcon: Bool = false
    @State private var showConfetti: Bool = false
    @State private var hapticTrigger: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(milestone.color.opacity(0.15))
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseIcon ? 1.15 : 1.0)

                        Circle()
                            .fill(milestone.color.opacity(0.08))
                            .frame(width: 160, height: 160)
                            .scaleEffect(pulseIcon ? 1.2 : 0.9)

                        Image(systemName: milestone.icon)
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(milestone.color)
                            .symbolEffect(.bounce, value: animateIn)
                    }

                    VStack(spacing: 8) {
                        Text("MILESTONE")
                            .font(.caption.weight(.heavy))
                            .tracking(3)
                            .foregroundStyle(milestone.color)

                        Text(milestone.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text(milestone.subtitle)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(KynexaTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }

                    HStack(spacing: 12) {
                        ShareLink(item: milestone.shareText) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.subheadline.weight(.bold))
                                Text("Share")
                                    .font(.headline.weight(.bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(KynexaTheme.heroGradient)
                            .clipShape(.rect(cornerRadius: 14))
                        }
                        .buttonStyle(PressScaleButtonStyle())

                        Button {
                            dismiss()
                        } label: {
                            Text("Continue")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(KynexaTheme.secondaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(KynexaTheme.cardSoft)
                                .clipShape(.rect(cornerRadius: 14))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(KynexaTheme.border)
                                }
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }
                }
                .padding(28)
                .background {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(KynexaTheme.card)
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(milestone.color.opacity(0.2))
                }
                .padding(.horizontal, 24)
                .scaleEffect(animateIn ? 1 : 0.8)
                .opacity(animateIn ? 1 : 0)

                Spacer()
            }
        }
        .sensoryFeedback(.success, trigger: hapticTrigger)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateIn = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.3)) {
                pulseIcon = true
            }
            hapticTrigger.toggle()
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            animateIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
