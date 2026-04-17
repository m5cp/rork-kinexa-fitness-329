import SwiftUI

struct ReflectionRingsHeroCard: View {
    @Environment(AppViewModel.self) private var appVM
    let nutritionVM: NutritionViewModel
    let ringsVM: ReflectionRingsViewModel

    var onTapRing: (RingType) -> Void
    var onOpenDetail: () -> Void

    @State private var animate: Bool = false
    @State private var showCelebration: Bool = false
    @State private var celebrationTrigger: Bool = false
    @State private var lastAllClosedDate: Date?

    private var today: Date { Calendar.current.startOfDay(for: .now) }

    private var closed: Set<RingType> {
        ringsVM.closedRings(on: today, appVM: appVM, nutritionVM: nutritionVM)
    }

    private var pointsToday: Int {
        ringsVM.pointsEarned(on: today, appVM: appVM, nutritionVM: nutritionVM)
    }

    private var streak: Int {
        ringsVM.currentStreak(appVM: appVM, nutritionVM: nutritionVM)
    }

    private var allClosed: Bool { closed.count == RingType.allCases.count }

    var body: some View {
        VStack(spacing: 16) {
            headerRow

            HStack(spacing: 18) {
                ringsStack
                    .frame(width: 132, height: 132)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(RingType.allCases) { ring in
                        ringLegendRow(ring)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            footerRow
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(KinexaTheme.card)
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#AF52DE").opacity(0.08),
                                    Color(hex: "#0A84FF").opacity(0.06),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
        }
        .clipShape(.rect(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22).stroke(KinexaTheme.border)
        }
        .overlay(alignment: .topTrailing) {
            if showCelebration {
                ConfettiBurst()
                    .allowsHitTesting(false)
            }
        }
        .sensoryFeedback(.success, trigger: celebrationTrigger)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.1)) {
                animate = true
            }
            checkCelebration()
        }
        .onChange(of: closed) { _, _ in
            checkCelebration()
        }
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("REFLECTION RINGS")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.4)
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text("Close your day")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
            }

            Spacer(minLength: 0)

            if streak > 0 {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.caption)
                    Text("\(streak)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(KinexaTheme.primaryText)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Color.orange.opacity(0.15))
                .clipShape(Capsule())
            }
        }
    }

    private var ringsStack: some View {
        ZStack {
            ForEach(Array(RingType.allCases.enumerated()), id: \.element) { index, ring in
                let progress = ringsVM.progress(for: ring, on: today, appVM: appVM, nutritionVM: nutritionVM)
                let inset = CGFloat(index) * 18
                ringView(ring: ring, progress: animate ? progress : 0)
                    .padding(inset)
            }
            VStack(spacing: 1) {
                Text("\(pointsToday)")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .contentTransition(.numericText())
                Text("PTS")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1.2)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onOpenDetail()
        }
    }

    private func ringView(ring: RingType, progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(ring.color.opacity(0.18), lineWidth: 8)
            Circle()
                .trim(from: 0, to: max(0.001, progress))
                .stroke(
                    ring.color,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.9, dampingFraction: 0.8), value: progress)
        }
    }

    private func ringLegendRow(_ ring: RingType) -> some View {
        Button {
            onTapRing(ring)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: ring.icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(ring.color)
                    .frame(width: 26, height: 26)
                    .background(ring.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                VStack(alignment: .leading, spacing: 1) {
                    Text(ring.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text(closed.contains(ring) ? "Closed" : ring.subtitle)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(closed.contains(ring) ? ring.color : KinexaTheme.tertiaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                if closed.contains(ring) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(ring.color)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var footerRow: some View {
        Button {
            onOpenDetail()
        } label: {
            HStack(spacing: 8) {
                if allClosed {
                    Image(systemName: "sparkles")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(hex: "#F59E0B"))
                    Text("All rings closed — +\(RingType.allRingsBonus) bonus!")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                } else {
                    Text("\(closed.count) of \(RingType.allCases.count) closed today")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                }

                Spacer(minLength: 0)

                Text("Details")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.accent)
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
            }
            .padding(.top, 4)
        }
        .buttonStyle(.plain)
    }

    private func checkCelebration() {
        guard allClosed else { return }
        let cal = Calendar.current
        if let last = lastAllClosedDate, cal.isDate(last, inSameDayAs: today) { return }
        lastAllClosedDate = today
        celebrationTrigger.toggle()
        withAnimation(.easeOut(duration: 0.3)) { showCelebration = true }
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.4)) { showCelebration = false }
            }
        }
    }
}

// MARK: - Confetti

struct ConfettiBurst: View {
    @State private var animate: Bool = false
    private let pieces: [ConfettiPiece] = (0..<24).map { _ in ConfettiPiece() }

    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .offset(
                        x: animate ? piece.endX : 0,
                        y: animate ? piece.endY : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: piece.duration),
                        value: animate
                    )
            }
        }
        .frame(width: 120, height: 120)
        .onAppear { animate = true }
    }
}

nonisolated struct ConfettiPiece: Identifiable, Sendable {
    let id = UUID()
    let color: Color
    let endX: CGFloat
    let endY: CGFloat
    let size: CGFloat
    let duration: Double

    init() {
        let palette: [Color] = [
            Color(hex: "#FF3B30"),
            Color(hex: "#FF9500"),
            Color(hex: "#FFCC00"),
            Color(hex: "#34C759"),
            Color(hex: "#0A84FF"),
            Color(hex: "#AF52DE")
        ]
        self.color = palette.randomElement() ?? .white
        self.endX = CGFloat.random(in: -80...80)
        self.endY = CGFloat.random(in: -60...120)
        self.size = CGFloat.random(in: 5...9)
        self.duration = Double.random(in: 0.9...1.6)
    }
}
