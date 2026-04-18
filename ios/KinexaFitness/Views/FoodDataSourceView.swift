import SwiftUI

struct FoodDataSourceView: View {
    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(KinexaTheme.accent.opacity(0.15))
                                .frame(width: 54, height: 54)
                            Image(systemName: "fork.knife")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(KinexaTheme.accent)
                        }

                        Text("Food Data Source")
                            .font(.title.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)

                        Text("Verified nutrition facts in this app are sourced from the USDA FoodData Central database.")
                            .font(.subheadline)
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        infoRow(icon: "checkmark.seal.fill", title: "USDA FoodData Central", subtitle: "Public nutrition database maintained by the U.S. Department of Agriculture.")
                        infoRow(icon: "sparkles", title: "AI Estimates", subtitle: "Scanned photo and text descriptions return AI-estimated macros and are always editable before saving.")
                        infoRow(icon: "hand.raised.fill", title: "Not Medical Advice", subtitle: "Nutrition values are estimates. Consult a registered dietitian for medical guidance.")
                    }
                    .padding(16)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
                    }
                    .elevatedCardShadow()

                    Link(destination: URL(string: "https://fdc.nal.usda.gov/")!) {
                        HStack(spacing: 10) {
                            Image(systemName: "link")
                            Text("Visit FoodData Central")
                                .font(.subheadline.weight(.bold))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(KinexaTheme.accent)
                        .padding(16)
                        .background(KinexaTheme.card)
                        .clipShape(.rect(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                        }
                        .elevatedCardShadow()
                    }

                    Text("The USDA does not endorse this app. Attribution is provided to credit the data source.")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
                .padding(20)
                .adaptiveContainer()
            }
        }
        .navigationTitle("References")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
    }

    private func infoRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.accent)
                .frame(width: 24)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
