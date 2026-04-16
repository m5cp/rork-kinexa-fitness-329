import SwiftUI
import MapKit

struct QuickStartDetailView: View {
    let record: QuickStartRecord

    private var hex: (String, String) { record.activity.gradientHex }

    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header

                    if record.routeCoordinates.count > 1 {
                        routeMap
                    }

                    statsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle(record.activity.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    ShareCardRenderer.presentShareSheet(
                        cardType: .quickStart(record: record),
                        date: record.startDate
                    )
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: hex.0).opacity(0.15))
                    .frame(width: 88, height: 88)

                Image(systemName: record.activity.icon)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Color(hex: hex.0))
            }

            Text(record.activity.rawValue)
                .font(.title2.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)

            Text(record.formattedDuration)
                .font(.system(size: 38, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(hex: hex.0))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var routeMap: some View {
        let coords = record.routeCoordinates.map(\.clCoordinate)
        Map {
            MapPolyline(coordinates: coords)
                .stroke(Color(hex: hex.0), lineWidth: 4)

            if let first = coords.first {
                Annotation("Start", coordinate: first) {
                    Circle()
                        .fill(KinexaTheme.success)
                        .frame(width: 12, height: 12)
                        .overlay { Circle().stroke(.white, lineWidth: 2) }
                }
            }

            if let last = coords.last {
                Annotation("End", coordinate: last) {
                    Circle()
                        .fill(KinexaTheme.danger)
                        .frame(width: 12, height: 12)
                        .overlay { Circle().stroke(.white, lineWidth: 2) }
                }
            }
        }
        .mapStyle(.standard)
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(KinexaTheme.border)
        }
    }

    private var statsCard: some View {
        VStack(spacing: 0) {
            if record.activity.usesGPS {
                HStack(spacing: 0) {
                    statItem(value: record.formattedDistance, label: "Distance")
                    Rectangle().fill(KinexaTheme.border).frame(width: 1, height: 40)
                    statItem(value: record.formattedPace, label: "Avg Pace")
                }
                .padding(.vertical, 18)

                Rectangle().fill(KinexaTheme.border).frame(height: 1)
            }

            HStack(spacing: 0) {
                statItem(value: record.formattedDuration, label: "Duration")
                Rectangle().fill(KinexaTheme.border).frame(width: 1, height: 40)
                statItem(value: dateString, label: "Date")
            }
            .padding(.vertical, 18)
        }
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
        f.dateFormat = "MMM d, h:mm a"
        return f.string(from: record.startDate)
    }
}
