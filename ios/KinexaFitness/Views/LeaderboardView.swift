import SwiftUI

struct LeaderboardView: View {
    @Environment(AppViewModel.self) private var appVM
    let nutritionVM: NutritionViewModel
    let ringsVM: ReflectionRingsViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var scope: Scope = .friends
    @State private var range: Range = .allTime
    @State private var showAddFriends: Bool = false

    enum Scope: String, CaseIterable, Identifiable {
        case friends = "Friends"
        case global = "Global"
        var id: String { rawValue }
    }

    enum Range: String, CaseIterable, Identifiable {
        case weekly = "This Week"
        case allTime = "All Time"
        var id: String { rawValue }
    }

    private var myPoints: Int {
        switch range {
        case .weekly: return ringsVM.weeklyPoints(appVM: appVM, nutritionVM: nutritionVM)
        case .allTime: return ringsVM.totalPoints(appVM: appVM, nutritionVM: nutritionVM)
        }
    }

    private var myStreak: Int {
        ringsVM.currentStreak(appVM: appVM, nutritionVM: nutritionVM)
    }

    private var me: LeaderboardEntry {
        LeaderboardEntry(
            id: UUID(),
            username: ringsVM.username.isEmpty ? "You" : ringsVM.username,
            avatarEmoji: "⭐️",
            points: myPoints,
            streak: myStreak,
            isMe: true
        )
    }

    private var entries: [LeaderboardEntry] {
        var list: [LeaderboardEntry] = [me]

        switch scope {
        case .friends:
            for f in ringsVM.friends {
                let pts = range == .weekly ? max(f.points / 8, 0) : f.points
                list.append(LeaderboardEntry(
                    id: f.id, username: f.username, avatarEmoji: f.avatarEmoji,
                    points: pts, streak: f.streak, isMe: false
                ))
            }
        case .global:
            list.append(contentsOf: Self.globalSeed(range: range))
        }

        return list.sorted { $0.points > $1.points }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    scopePicker
                    rangePicker
                    podiumSection
                    rankingsList

                    if scope == .friends {
                        addFriendsButton
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showAddFriends) {
                AddFriendsSheet(ringsVM: ringsVM)
            }
        }
    }

    private var scopePicker: some View {
        Picker("", selection: $scope) {
            ForEach(Scope.allCases) { s in
                Text(s.rawValue).tag(s)
            }
        }
        .pickerStyle(.segmented)
    }

    private var rangePicker: some View {
        HStack(spacing: 8) {
            ForEach(Range.allCases) { r in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { range = r }
                } label: {
                    Text(r.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(range == r ? .white : KinexaTheme.secondaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(range == r ? KinexaTheme.accent : KinexaTheme.cardSoft)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var podiumSection: some View {
        let top3 = Array(entries.prefix(3))
        if top3.count >= 3 {
            HStack(alignment: .bottom, spacing: 10) {
                podiumColumn(entry: top3[1], rank: 2, height: 90)
                podiumColumn(entry: top3[0], rank: 1, height: 110)
                podiumColumn(entry: top3[2], rank: 3, height: 70)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }

    private func podiumColumn(entry: LeaderboardEntry, rank: Int, height: CGFloat) -> some View {
        let colors: [Color] = [
            Color(hex: "#F59E0B"),
            Color(hex: "#9CA3AF"),
            Color(hex: "#B45309")
        ]
        let color = colors[min(rank - 1, 2)]

        return VStack(spacing: 8) {
            Text(entry.avatarEmoji)
                .font(.system(size: 32))
                .frame(width: 56, height: 56)
                .background(color.opacity(0.2))
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(color, lineWidth: 2)
                }

            Text(entry.username)
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
                .lineLimit(1)

            Text("\(entry.points)")
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(color)

            VStack(spacing: 2) {
                Text("\(rank)")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background {
                LinearGradient(
                    colors: [color, color.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipShape(.rect(topLeadingRadius: 10, topTrailingRadius: 10))
        }
        .frame(maxWidth: .infinity)
    }

    private var rankingsList: some View {
        VStack(spacing: 8) {
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                rankRow(entry: entry, rank: index + 1)
            }
        }
    }

    private func rankRow(entry: LeaderboardEntry, rank: Int) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.caption.weight(.heavy))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .frame(width: 26)

            Text(entry.avatarEmoji)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(KinexaTheme.cardSoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(entry.username)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    if entry.isMe {
                        Text("YOU")
                            .font(.caption2.weight(.heavy))
                            .tracking(0.8)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(KinexaTheme.accent)
                            .clipShape(Capsule())
                    }
                }
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.caption2)
                    Text("\(entry.streak) day\(entry.streak == 1 ? "" : "s")")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
            }

            Spacer(minLength: 0)

            Text("\(entry.points)")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(KinexaTheme.primaryText)
                .contentTransition(.numericText())
        }
        .padding(12)
        .background(entry.isMe ? KinexaTheme.accent.opacity(0.1) : KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(entry.isMe ? KinexaTheme.accent.opacity(0.4) : KinexaTheme.border)
        }
    }

    private var addFriendsButton: some View {
        Button {
            showAddFriends = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "person.badge.plus")
                    .font(.subheadline.weight(.bold))
                Text("Add Friends")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(KinexaTheme.accent)
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    static func globalSeed(range: LeaderboardView.Range) -> [LeaderboardEntry] {
        let names = [
            ("Maya", "🔥"), ("Chris", "⚡️"), ("Taylor", "🏋️‍♀️"),
            ("Jamie", "🥇"), ("Riley", "💪"), ("Morgan", "🏃"),
            ("Avery", "🧘"), ("Casey", "🚴"), ("Drew", "🥗"),
            ("Quinn", "🌊"), ("Parker", "🔋"), ("Reese", "🎯")
        ]
        let weeklyMultiplier: Double = range == .weekly ? 0.2 : 1.0
        return names.enumerated().map { idx, t in
            let base = Int(Double(3200 - idx * 180) * weeklyMultiplier)
            return LeaderboardEntry(
                id: UUID(),
                username: t.0,
                avatarEmoji: t.1,
                points: max(base, 40),
                streak: max(20 - idx, 0),
                isMe: false
            )
        }
    }
}

struct LeaderboardEntry: Identifiable, Hashable {
    let id: UUID
    let username: String
    let avatarEmoji: String
    let points: Int
    let streak: Int
    let isMe: Bool
}

struct AddFriendsSheet: View {
    let ringsVM: ReflectionRingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var username: String = ""
    @State private var code: String = ""
    @State private var addTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    shareCodeCard

                    VStack(alignment: .leading, spacing: 12) {
                        Text("ADD A FRIEND")
                            .font(.caption.weight(.heavy))
                            .tracking(1.2)
                            .foregroundStyle(KinexaTheme.tertiaryText)

                        TextField("Friend's username", text: $username)
                            .padding(14)
                            .background(KinexaTheme.cardSoft)
                            .clipShape(.rect(cornerRadius: 12))
                            .foregroundStyle(KinexaTheme.primaryText)
                            .textInputAutocapitalization(.never)

                        TextField("Share code (e.g. ABC123)", text: $code)
                            .padding(14)
                            .background(KinexaTheme.cardSoft)
                            .clipShape(.rect(cornerRadius: 12))
                            .foregroundStyle(KinexaTheme.primaryText)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()

                        Button {
                            addTrigger.toggle()
                            ringsVM.addFriend(username: username, code: code)
                            username = ""
                            code = ""
                        } label: {
                            Text("Add Friend")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background {
                                    RoundedRectangle(cornerRadius: 12).fill(KinexaTheme.accent)
                                }
                        }
                        .buttonStyle(.plain)
                        .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty || code.trimmingCharacters(in: .whitespaces).isEmpty)
                        .sensoryFeedback(.success, trigger: addTrigger)
                    }

                    if !ringsVM.friends.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("YOUR FRIENDS")
                                .font(.caption.weight(.heavy))
                                .tracking(1.2)
                                .foregroundStyle(KinexaTheme.tertiaryText)

                            ForEach(ringsVM.friends) { friend in
                                friendRow(friend)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var shareCodeCard: some View {
        VStack(spacing: 12) {
            Text("YOUR SHARE CODE")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)

            Text(ringsVM.shareCode)
                .font(.system(size: 32, weight: .heavy, design: .monospaced))
                .tracking(4)
                .foregroundStyle(KinexaTheme.primaryText)

            Button {
                UIPasteboard.general.string = ringsVM.shareCode
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "doc.on.doc.fill")
                        .font(.caption.weight(.bold))
                    Text("Copy Code")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(KinexaTheme.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(KinexaTheme.accent.opacity(0.15))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Text("Share this code with friends so they can add you.")
                .font(.caption.weight(.medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
        }
    }

    private func friendRow(_ friend: Friend) -> some View {
        HStack(spacing: 12) {
            Text(friend.avatarEmoji)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(KinexaTheme.cardSoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(friend.username)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(friend.shareCode)
                    .font(.caption2.weight(.medium).monospaced())
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            Spacer(minLength: 0)

            Button {
                ringsVM.removeFriend(id: friend.id)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(KinexaTheme.danger)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border)
        }
    }
}
