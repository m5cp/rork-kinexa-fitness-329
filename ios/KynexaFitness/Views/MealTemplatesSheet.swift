import SwiftUI

struct MealTemplatesSheet: View {
    @Environment(\.dismiss) private var dismiss
    let nutritionVM: NutritionViewModel
    var initialMealType: MealType = .lunch
    var onApplied: (() -> Void)? = nil

    @State private var pendingTemplate: MealTemplate?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    if nutritionVM.mealTemplates.isEmpty {
                        emptyState
                    } else {
                        ForEach(sortedTemplates) { template in
                            templateRow(template)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(KynexaTheme.background.ignoresSafeArea())
            .navigationTitle("Meal Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KynexaTheme.secondaryText)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(item: $pendingTemplate) { template in
            ServingAdjusterSheet(
                title: template.title,
                foods: template.foods,
                defaultMealType: template.mealType
            ) { multiplier, mealType in
                nutritionVM.applyTemplate(template, mealType: mealType, multiplier: multiplier)
                onApplied?()
                dismiss()
            }
        }
    }

    private var sortedTemplates: [MealTemplate] {
        nutritionVM.mealTemplates.sorted { $0.lastUsed > $1.lastUsed }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 42))
                .foregroundStyle(KynexaTheme.tertiaryText)
            Text("No templates yet")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KynexaTheme.secondaryText)
            Text("Open any logged meal and tap \"Save as Template\" to build your quick-log library.")
                .font(.caption)
                .foregroundStyle(KynexaTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private func templateRow(_ template: MealTemplate) -> some View {
        let n = template.totalNutrition
        return HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: template.mealType.color).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: template.mealType.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: template.mealType.color))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(template.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text("\(n.calories) cal")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KynexaTheme.secondaryText)
                    Text("· P\(Int(n.protein)) C\(Int(n.carbs)) F\(Int(n.fat))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(KynexaTheme.tertiaryText)
                    if n.alcohol > 0 {
                        Text("· A\(Int(n.alcohol))")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(hex: "#A855F7"))
                    }
                }
                Text(template.foods.map(\.name).joined(separator: ", "))
                    .font(.system(size: 10))
                    .foregroundStyle(KynexaTheme.tertiaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Button {
                pendingTemplate = template
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .heavy))
                    Text("Log")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(KynexaTheme.accent)
                .clipShape(Capsule())
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(12)
        .background(KynexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 14).stroke(KynexaTheme.border)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                nutritionVM.deleteTemplate(id: template.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                nutritionVM.deleteTemplate(id: template.id)
            } label: {
                Label("Delete Template", systemImage: "trash")
            }
        }
    }
}
