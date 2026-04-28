import SwiftUI

struct AgeGateView: View {
    var onConfirm: () -> Void

    @State private var showDeclineAlert = false

    var body: some View {
        ZStack {
            KynexaTheme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "person.badge.shield.checkmark.fill")
                    .font(.system(size: 72, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.tint)

                VStack(spacing: 12) {
                    Text("Age Verification")
                        .font(.largeTitle.bold())

                    Text("Kynexa Fitness is intended for users 18 years of age or older.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        onConfirm()
                    } label: {
                        Text("I am 18 or older")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        showDeclineAlert = true
                    } label: {
                        Text("I am under 18")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 24)

                Text("By continuing, you confirm that you meet the minimum age requirement to use this app.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
            }
        }
        .alert("Sorry", isPresented: $showDeclineAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You must be 18 or older to use Kynexa Fitness.")
        }
    }
}

#Preview {
    AgeGateView(onConfirm: {})
}
