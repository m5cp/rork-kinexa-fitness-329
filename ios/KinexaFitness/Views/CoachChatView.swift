import SwiftUI

struct CoachChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreViewModel.self) private var store
    @State private var chat = CoachChatService.shared
    @State private var input: String = ""
    @State private var showUpgrade: Bool = false
    @FocusState private var inputFocused: Bool

    private let prompts: [(icon: String, label: String, text: String)] = [
        ("calendar", "Plan my week", "Give me a simple 4-day plan that mixes strength and cardio for this week."),
        ("arrow.triangle.2.circlepath", "Swap an exercise", "Suggest a swap for barbell squats if I only have dumbbells."),
        ("figure.strengthtraining.functional", "Explain a movement", "Explain proper form for a Romanian deadlift in plain language."),
        ("flame", "Quick combo", "Give me a 20-minute push/pull dumbbell combo.")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    usageHeader

                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                if chat.messages.count <= 1 {
                                    promptsSection
                                        .padding(.horizontal, 16)
                                        .padding(.top, 8)
                                }

                                ForEach(chat.messages) { msg in
                                    MessageBubble(message: msg)
                                        .id(msg.id)
                                        .padding(.horizontal, 16)
                                }

                                if chat.isSending {
                                    TypingBubble()
                                        .padding(.horizontal, 16)
                                        .id("typing")
                                }

                                if chat.hasReachedLimit && !store.isPremium {
                                    upgradeCard
                                        .padding(.horizontal, 16)
                                        .padding(.top, 8)
                                }

                                Color.clear.frame(height: 8).id("bottom")
                            }
                            .padding(.vertical, 12)
                        }
                        .onChange(of: chat.messages.count) { _, _ in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                        .onChange(of: chat.isSending) { _, _ in
                            withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                        }
                    }

                    inputBar
                }
            }
            .navigationTitle("Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        chat.clearConversation()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }
                    .accessibilityLabel("Reset conversation")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }
            }
            .sheet(isPresented: $showUpgrade) {
                UpgradeView()
            }
            .onAppear {
                chat.isPremium = store.isPremium
            }
            .onChange(of: store.isPremium) { _, newValue in
                chat.isPremium = newValue
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var usageHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "bolt.fill")
                .font(.caption2.weight(.bold))
                .foregroundStyle(KinexaTheme.accent)
            Text("\(chat.remainingToday) of \(chat.dailyLimit) messages left today")
                .font(.caption.weight(.medium))
                .foregroundStyle(KinexaTheme.secondaryText)
            Spacer()
            if !store.isPremium {
                Button {
                    showUpgrade = true
                } label: {
                    Text("Upgrade")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(KinexaTheme.background)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(KinexaTheme.border)
                .frame(height: 0.5)
        }
    }

    private var promptsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Try asking")
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .textCase(.uppercase)
                .tracking(0.8)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                ForEach(prompts, id: \.label) { item in
                    Button {
                        send(item.text)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: item.icon)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KinexaTheme.accent)
                                .frame(width: 30, height: 30)
                                .background(KinexaTheme.accent.opacity(0.12))
                                .clipShape(.rect(cornerRadius: 8))

                            Text(item.label)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KinexaTheme.primaryText)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(KinexaTheme.card)
                        .clipShape(.rect(cornerRadius: 14))
                        .elevatedCardShadow()
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(KinexaTheme.border)
                        }
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
            }
        }
    }

    private var upgradeCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "crown.fill")
                .font(.title3)
                .foregroundStyle(KinexaTheme.accent)
            Text("You've used your \(chat.dailyLimit) messages today")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
                .multilineTextAlignment(.center)
            Text("Upgrade to Pro for 50 coach messages per day, plus expanded workout and nutrition tools.")
                .font(.caption)
                .foregroundStyle(KinexaTheme.secondaryText)
                .multilineTextAlignment(.center)
            Button {
                showUpgrade = true
            } label: {
                Text("See Pro")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(KinexaTheme.heroGradient)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())
            .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(KinexaTheme.border)
        }
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Ask your coach…", text: $input, axis: .vertical)
                .lineLimit(1...5)
                .textFieldStyle(.plain)
                .focused($inputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(KinexaTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(KinexaTheme.border)
                }
                .disabled(chat.hasReachedLimit)

            Button {
                send(input)
            } label: {
                Image(systemName: "arrow.up")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(canSend ? KinexaTheme.accent : KinexaTheme.tertiaryText.opacity(0.4))
                    .clipShape(Circle())
            }
            .disabled(!canSend)
            .sensoryFeedback(.impact(weight: .medium), trigger: chat.messages.count)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(KinexaTheme.background)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(KinexaTheme.border)
                .frame(height: 0.5)
        }
    }

    private var canSend: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !chat.isSending
        && !chat.hasReachedLimit
    }

    private func send(_ text: String) {
        let toSend = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !toSend.isEmpty else { return }
        input = ""
        inputFocused = false
        Task { await chat.sendMessage(toSend) }
    }
}

private struct MessageBubble: View {
    let message: CoachMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .user { Spacer(minLength: 40) }

            if message.role == .assistant {
                ZStack {
                    Circle()
                        .fill(KinexaTheme.accent.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: "sparkles")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.accent)
                }
            }

            Text(message.text)
                .font(.subheadline)
                .foregroundStyle(message.role == .user ? .white : KinexaTheme.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    if message.role == .user {
                        KinexaTheme.accent
                    } else {
                        KinexaTheme.card
                    }
                }
                .clipShape(.rect(cornerRadius: 16))
                .overlay {
                    if message.role == .assistant {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(KinexaTheme.border)
                    }
                }
                .shadow(color: KinexaTheme.cardShadow.opacity(message.role == .user ? 0 : 1), radius: 3, y: 1)
                .textSelection(.enabled)

            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }
}

private struct TypingBubble: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(KinexaTheme.accent.opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
            }

            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(KinexaTheme.tertiaryText)
                        .frame(width: 6, height: 6)
                        .opacity(phase == i ? 1 : 0.3)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(KinexaTheme.border)
            }

            Spacer(minLength: 40)
        }
        .onAppear {
            Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(350))
                    withAnimation(.easeInOut(duration: 0.2)) {
                        phase = (phase + 1) % 3
                    }
                }
            }
        }
    }
}
