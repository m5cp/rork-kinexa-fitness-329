import SwiftUI

struct CompletedWorkoutsListView: View {
    @Environment(AppViewModel.self) private var vm

    @State private var selectedRecord: CompletedWorkoutRecord?
    @State private var showDetail: Bool = false
    @State private var shareRecord: CompletedWorkoutRecord?


    private var groupedRecords: [(String, [CompletedWorkoutRecord])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: vm.completedRecords.sorted { $0.date > $1.date }) {
            formatter.string(from: $0.date)
        }

        return grouped.sorted { lhs, rhs in
            guard let l = lhs.value.first?.date, let r = rhs.value.first?.date else { return false }
            return l > r
        }
    }

    var body: some View {
        ZStack {
            KynexaTheme.background.ignoresSafeArea()

            if vm.completedRecords.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(KynexaTheme.tertiaryText)

                    Text("No Completed Workouts")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(KynexaTheme.secondaryText)

                    Text("Workouts you complete will appear here.")
                        .font(.subheadline)
                        .foregroundStyle(KynexaTheme.tertiaryText)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(groupedRecords, id: \.0) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(section.0)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(KynexaTheme.secondaryText)
                                    .padding(.horizontal, 4)

                                ForEach(section.1) { record in
                                    Button {
                                        selectedRecord = record
                                        showDetail = true
                                    } label: {
                                        recordRow(record)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Completed Workouts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KynexaTheme.background, for: .navigationBar)
        
        .navigationDestination(isPresented: $showDetail) {
            if let record = selectedRecord {
                CompletedWorkoutDetailView(record: record)
            }
        }
        .sheet(item: $shareRecord) { record in
            CompletedWorkoutShareSheet(record: record)
        }
    }

    private func recordRow(_ record: CompletedWorkoutRecord) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(KynexaTheme.success)
                .frame(width: 44, height: 44)
                .background(KynexaTheme.success.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KynexaTheme.primaryText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label("\(record.exerciseCount) exercises", systemImage: "list.bullet")
                    Text(formatDate(record.date))
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(KynexaTheme.tertiaryText)
            }

            Spacer(minLength: 0)

            Button {
                shareRecord = record
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KynexaTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(KynexaTheme.accent.opacity(0.12))
                    .clipShape(Circle())
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(KynexaTheme.tertiaryText)
        }
        .padding(14)
        .background(KynexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(KynexaTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .elevatedCardShadow()
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f.string(from: date)
    }
}
