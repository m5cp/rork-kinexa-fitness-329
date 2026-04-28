import SwiftUI

struct UnavailableFallbackView: View {
    let title: String
    let message: String
    let action: String
    let onAction: () -> Void

    var body: some View {
        ZStack {
            KynexaTheme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 44))
                        .foregroundStyle(KynexaTheme.accent.opacity(0.5))

                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(KynexaTheme.primaryText)

                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(KynexaTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                Button {
                    onAction()
                } label: {
                    Text(action)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(height: 52)
                        .frame(maxWidth: .infinity)
                        .background(KynexaTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .toolbarBackground(KynexaTheme.background, for: .navigationBar)
        
    }
}
