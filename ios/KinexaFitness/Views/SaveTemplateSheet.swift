import SwiftUI

struct SaveTemplateSheet: View {
    @Environment(\.dismiss) private var dismiss
    let meal: MealEntry
    let onSave: (String) -> Void

    @State private var title: String = ""
    @State private var isSaving: Bool = false
    @FocusState private var focused: Bool

    private let suggestions: [String] = [
        "High Protein Breakfast",
        "Chicken and Rice Lunch",
        "Recovery Shake",
        "Weekend Drinks",
        "Quick Snack"
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name this template")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                        TextField("e.g. High Protein Breakfast", text: $title)
                            .font(.subheadline)
                            .foregroundStyle(KinexaTheme.primaryText)
                            .padding(14)
                            .background(KinexaTheme.cardSoft)
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border)
                            }
                            .focused($focused)
                            .submitLabel(.done)
                            .onSubmit(saveIfValid)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Suggestions")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                        FlowLayout(spacing: 8) {
                            ForEach(suggestions, id: \.self) { s in
                                Button {
                                    title = s
                                } label: {
                                    Text(s)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(KinexaTheme.primaryText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(KinexaTheme.cardSoft)
                                        .clipShape(Capsule())
                                        .overlay {
                                            Capsule().stroke(KinexaTheme.border)
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    summary
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Save as Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveIfValid)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(title.trimmingCharacters(in: .whitespaces).isEmpty ? KinexaTheme.tertiaryText : KinexaTheme.success)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .onAppear { focused = true }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func saveIfValid() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSaving else { return }
        isSaving = true
        onSave(trimmed)
        dismiss()
    }

    private var summary: some View {
        let n = meal.totalNutrition
        return VStack(alignment: .leading, spacing: 10) {
            Text("What's in it")
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.tertiaryText)
            Text(meal.foods.map(\.name).joined(separator: ", "))
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.primaryText)
                .lineSpacing(2)
            HStack(spacing: 10) {
                Text("\(n.calories) cal")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.success)
                Text("P \(Int(n.protein))g · C \(Int(n.carbs))g · F \(Int(n.fat))g\(n.alcohol > 0 ? " · A \(Int(n.alcohol))g" : "")")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
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
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
