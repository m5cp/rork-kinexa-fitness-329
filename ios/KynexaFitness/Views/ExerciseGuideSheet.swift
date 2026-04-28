import SwiftUI

struct ExerciseGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    let exerciseName: String
    let accent: Color
    var muscleTag: String?
    var equipment: String?

    init(
        exerciseName: String,
        accent: Color = Color(hex: "#6366F1"),
        muscleTag: String? = nil,
        equipment: String? = nil
    ) {
        self.exerciseName = exerciseName
        self.accent = accent
        self.muscleTag = muscleTag
        self.equipment = equipment
    }

    private var guide: MovementGuide {
        MovementGuideLibrary.guide(for: exerciseName)
    }

    private var hasGuide: Bool {
        let key = exerciseName.lowercased()
        return MovementGuideLibrary.hasGuide(for: key)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    if hasGuide {
                        section(title: "WHAT IT IS") {
                            Text(guide.whatIsIt)
                                .font(.subheadline)
                                .foregroundStyle(KynexaTheme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if let muscles = guide.primaryMuscles ?? muscleTag {
                            section(title: "PRIMARY MUSCLES") {
                                Text(muscles)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(KynexaTheme.primaryText)
                            }
                        }

                        section(title: "HOW TO DO IT") {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(Array(guide.howTo.enumerated()), id: \.offset) { idx, step in
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("\(idx + 1)")
                                            .font(.caption.weight(.heavy))
                                            .foregroundStyle(.white)
                                            .frame(width: 22, height: 22)
                                            .background(accent)
                                            .clipShape(Circle())
                                        Text(step)
                                            .font(.subheadline)
                                            .foregroundStyle(KynexaTheme.secondaryText)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }

                        if !guide.tips.isEmpty {
                            section(title: "FORM TIPS") {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(guide.tips, id: \.self) { tip in
                                        HStack(alignment: .top, spacing: 10) {
                                            Image(systemName: "lightbulb.fill")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(Color(hex: "#F59E0B"))
                                            Text(tip)
                                                .font(.subheadline)
                                                .foregroundStyle(KynexaTheme.secondaryText)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                        }

                        if !guide.alternatives.isEmpty {
                            section(title: "ALTERNATIVES") {
                                FlowLayout(spacing: 8) {
                                    ForEach(guide.alternatives, id: \.self) { alt in
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.triangle.swap")
                                                .font(.caption2.weight(.bold))
                                            Text(alt).font(.caption.weight(.semibold))
                                        }
                                        .foregroundStyle(accent)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(accent.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(KynexaTheme.background.ignoresSafeArea())
            .navigationTitle("Exercise Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(KynexaTheme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KynexaTheme.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(KynexaTheme.background)
        .presentationContentInteraction(.scrolls)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(exerciseName)
                .font(.title2.weight(.bold))
                .foregroundStyle(KynexaTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                if let tag = muscleTag {
                    tagPill(tag, color: accent)
                }
                if let eq = equipment, !eq.isEmpty {
                    tagPill(eq, color: KynexaTheme.secondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            LinearGradient(
                colors: [accent.opacity(0.18), accent.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).stroke(accent.opacity(0.25))
        }
    }

    private func tagPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundStyle(KynexaTheme.tertiaryText)
            Text("No guide available")
                .font(.headline.weight(.semibold))
                .foregroundStyle(KynexaTheme.primaryText)
            Text("This looks like a custom exercise. Add your own notes in the routine to track how you'd like to perform it.")
                .font(.subheadline)
                .foregroundStyle(KynexaTheme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.heavy))
                .tracking(1.1)
                .foregroundStyle(KynexaTheme.tertiaryText)
            content()
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            totalWidth = max(totalWidth, x)
        }

        return CGSize(width: totalWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
