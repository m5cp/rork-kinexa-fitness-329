import SwiftUI

struct DailyInsightSheet: View {
    let nutritionVM: NutritionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if nutritionVM.isAnalyzing {
                        analyzingView
                    } else if let insight = nutritionVM.dailyInsight {
                        insightContent(insight)
                    } else {
                        noDataView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Daily Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var analyzingView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(Color(hex: "#6366F1"))
                .symbolEffect(.pulse, options: .repeating)

            Text("Analyzing your nutrition...")
                .font(.headline.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)

            Text("Gemini is reviewing your meals and macro balance")
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .multilineTextAlignment(.center)

            ProgressView()
                .tint(Color(hex: "#6366F1"))
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func insightContent(_ insight: GeminiDailyInsight) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.pie.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(hex: "#6366F1"))
                    Text("Overview")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                }

                Text(insight.overview)
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineSpacing(4)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(KinexaTheme.border)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "scale.3d")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(hex: "#3B82F6"))
                    Text("Macro Balance")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                }

                Text(insight.macroBalance)
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineSpacing(4)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(KinexaTheme.border)
            }

            if !insight.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "list.bullet.clipboard.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.success)
                        Text("Recommendations")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                    }

                    ForEach(Array(insight.recommendations.enumerated()), id: \.offset) { index, rec in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.black))
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(KinexaTheme.success)
                                .clipShape(Circle())
                            Text(rec)
                                .font(.subheadline)
                                .foregroundStyle(KinexaTheme.primaryText)
                                .lineSpacing(3)
                        }
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(KinexaTheme.border)
                }
            }

            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(hex: "#F59E0B"))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Meal Timing")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Text(insight.mealTimingTip)
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.primaryText)
                        .lineSpacing(3)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(KinexaTheme.card)
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(hex: "#F59E0B").opacity(0.05))
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: "#F59E0B").opacity(0.15))
                }
            }
            .clipShape(.rect(cornerRadius: 18))

            Text("Powered by Gemini AI")
                .font(.caption2.weight(.medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var noDataView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 40))
                .foregroundStyle(KinexaTheme.tertiaryText)
            Text("No analysis available")
                .font(.headline)
                .foregroundStyle(KinexaTheme.secondaryText)
            Text("Log some meals first, then come back for AI-powered insights.")
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
    }
}
