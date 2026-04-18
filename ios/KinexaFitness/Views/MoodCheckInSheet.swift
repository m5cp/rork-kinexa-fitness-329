import SwiftUI

struct MoodCheckInSheet: View {
    let ringsVM: ReflectionRingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedLevel: MoodLevel?
    @State private var note: String = ""
    @State private var saveTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("How are you feeling?")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text("Quick check-in closes your Mood ring")
                            .font(.subheadline)
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }
                    .padding(.top, 12)

                    HStack(spacing: 10) {
                        ForEach(MoodLevel.allCases) { level in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    selectedLevel = level
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Text(level.emoji)
                                        .font(.system(size: 34))
                                    Text(level.label)
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(selectedLevel == level ? .white : KinexaTheme.secondaryText)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(selectedLevel == level ? level.color : KinexaTheme.cardSoft)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedLevel == level ? level.color : KinexaTheme.border, lineWidth: 1)
                                }
                                .scaleEffect(selectedLevel == level ? 1.05 : 1.0)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (optional)")
                            .font(.caption.weight(.heavy))
                            .tracking(1.0)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                        TextField("What's on your mind?", text: $note, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(KinexaTheme.cardSoft)
                            .clipShape(.rect(cornerRadius: 12))
                            .foregroundStyle(KinexaTheme.primaryText)
                    }

                    Button {
                        guard let level = selectedLevel else { return }
                        saveTrigger.toggle()
                        ringsVM.logMood(level, note: note)
                        dismiss()
                    } label: {
                        Text("Log Mood")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedLevel?.color ?? KinexaTheme.accent)
                            }
                    }
                    .disabled(selectedLevel == nil)
                    .opacity(selectedLevel == nil ? 0.5 : 1)
                    .sensoryFeedback(.success, trigger: saveTrigger)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Mood Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
        }
        .onAppear {
            if let existing = ringsVM.todayMood {
                selectedLevel = existing.level
                note = existing.note
            }
        }
    }
}
