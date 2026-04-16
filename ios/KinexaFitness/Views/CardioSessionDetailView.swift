import SwiftUI

struct CardioSessionDetailView: View {
    let session: CardioSession

    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    statsCard
                    if !session.notes.isEmpty {
                        notesCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle(session.workoutName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#FF6B35").opacity(0.15))
                    .frame(width: 84, height: 84)
                Image(systemName: "heart.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Color(hex: "#FF6B35"))
            }

            Text(session.workoutName)
                .font(.title2.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
                .multilineTextAlignment(.center)

            Text(session.category)
                .font(.caption.weight(.semibold))
                .foregroundStyle(KinexaTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(KinexaTheme.accent.opacity(0.12))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var statsCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                statItem(value: "\(session.durationMinutes) min", label: "Duration")
                Rectangle().fill(KinexaTheme.border).frame(width: 1, height: 40)
                statItem(value: session.distanceMiles.map { String(format: "%.2f mi", $0) } ?? "—", label: "Distance")
            }
            .padding(.vertical, 18)

            Rectangle().fill(KinexaTheme.border).frame(height: 1)

            HStack(spacing: 0) {
                statItem(value: session.caloriesBurned.map { "\($0)" } ?? "—", label: "Calories")
                Rectangle().fill(KinexaTheme.border).frame(width: 1, height: 40)
                statItem(value: dateString, label: "Date")
            }
            .padding(.vertical, 18)
        }
        .premiumCard()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTES")
                .font(.caption2.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(KinexaTheme.tertiaryText)

            Text(session.notes)
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .premiumCard()
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: session.date)
    }
}
