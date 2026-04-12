import SwiftUI

struct NutritionPartnerView: View {
    @Environment(\.dismiss) private var dismiss

    private let partnerWebsite: String = "https://www.yournutritionpartner.com"
    private let partnerEmail: String = "nutrition@yourpartner.com"

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        heroHeader
                        aboutSection
                        contactActions
                        disclaimerNote
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                    .adaptiveContainer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var heroHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#059669"), Color(hex: "#10B981")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color(hex: "#059669").opacity(0.3), radius: 20, y: 10)

            VStack(spacing: 6) {
                Text("Nutrition Partner")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)

                Text("Personalized Nutrition Consultations")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(KinexaTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text("ABOUT")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 14) {
                Text("Get personalized nutrition plans, dietary guidance, and one-on-one consultations from our certified nutrition partner.")
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .lineSpacing(4)

                VStack(spacing: 10) {
                    serviceBullet(icon: "chart.bar.doc.horizontal", text: "Custom meal plans tailored to your goals")
                    serviceBullet(icon: "person.fill.questionmark", text: "One-on-one dietary consultations")
                    serviceBullet(icon: "heart.text.square", text: "Supplement & recovery guidance")
                    serviceBullet(icon: "calendar.badge.clock", text: "Ongoing support & plan adjustments")
                }
            }
            .padding(18)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border)
            }
        }
    }

    private func serviceBullet(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(hex: "#10B981"))
                .frame(width: 28, height: 28)
                .background(Color(hex: "#10B981").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(KinexaTheme.primaryText)

            Spacer(minLength: 0)
        }
    }

    private var contactActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "phone.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text("GET IN TOUCH")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 12) {
                Button {
                    if let url = URL(string: partnerWebsite) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "globe")
                            .font(.body.weight(.semibold))
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
                            Text("Visit Website")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KinexaTheme.primaryText)
                            Text(partnerWebsite.replacingOccurrences(of: "https://www.", with: ""))
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "arrow.up.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    .padding(14)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    if let url = URL(string: "mailto:\(partnerEmail)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#2E86DE"), Color(hex: "#54A0FF")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(.rect(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Send Email")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KinexaTheme.primaryText)
                            Text(partnerEmail)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "arrow.up.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    .padding(14)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }

    private var disclaimerNote: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle")
                .font(.caption.weight(.semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)

            Text("Kinexa Fit partners with independent nutrition professionals. All consultations are provided directly by the partner and are not medical advice.")
                .font(.caption2)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .lineSpacing(3)
        }
        .padding(14)
        .background(KinexaTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 12))
    }
}
