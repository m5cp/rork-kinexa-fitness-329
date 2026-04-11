import SwiftUI

struct PerformanceHighlightsView: View {
    let highlights: [PerformanceHighlight]
    let showEmptyState: Bool

    init(highlights: [PerformanceHighlight], showEmptyState: Bool = false) {
        self.highlights = highlights
        self.showEmptyState = showEmptyState
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
                .padding(.bottom, 16)

            if highlights.isEmpty {
                emptyState
            } else {
                VStack(spacing: 10) {
                    ForEach(highlights) { highlight in
                        PerformanceHighlightRow(highlight: highlight)
                    }
                }

                metadataRow
                    .padding(.top, 14)
            }
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(KinexaTheme.card)
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [KinexaTheme.accent.opacity(0.04), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 24)
                    .stroke(KinexaTheme.accent.opacity(0.12))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
    }

    private var headerRow: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(KinexaTheme.accent.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Performance Highlights")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)

                if !highlights.isEmpty {
                    Text("\(highlights.count) highlight\(highlights.count == 1 ? "" : "s")")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
            }

            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.flattrend.xyaxis")
                .font(.system(size: 28))
                .foregroundStyle(KinexaTheme.tertiaryText)

            Text("No highlights yet")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KinexaTheme.secondaryText)

            Text("Complete workouts and log scores to build your highlights.")
                .font(.caption)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private var metadataRow: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(KinexaTheme.success)
                .frame(width: 5, height: 5)

            Text("Updated today")
                .font(.caption2.weight(.medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct PerformanceHighlightRow: View {
    let highlight: PerformanceHighlight

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 38, height: 38)

                Image(systemName: highlight.icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(highlight.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)

                if let detail = highlight.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
            }

            Spacer(minLength: 0)

            typeBadge
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(KinexaTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: 0.5)
        }
    }

    private var iconColor: Color {
        highlight.isPositive ? KinexaTheme.success : KinexaTheme.warning
    }

    private var borderColor: Color {
        switch highlight.type {
        case .personalBest: return KinexaTheme.success.opacity(0.2)
        case .eventImprovement: return KinexaTheme.accent.opacity(0.15)
        case .scoreChange: return highlight.isPositive ? KinexaTheme.success.opacity(0.15) : KinexaTheme.warning.opacity(0.15)
        case .streak: return KinexaTheme.warning.opacity(0.15)
        default: return KinexaTheme.border
        }
    }

    @ViewBuilder
    private var typeBadge: some View {
        switch highlight.type {
        case .personalBest:
            Text("PB")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(KinexaTheme.success)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(KinexaTheme.success.opacity(0.12))
                .clipShape(Capsule())
        case .streak:
            Image(systemName: "flame.fill")
                .font(.caption2.weight(.bold))
                .foregroundStyle(KinexaTheme.warning)
        default:
            EmptyView()
        }
    }
}
