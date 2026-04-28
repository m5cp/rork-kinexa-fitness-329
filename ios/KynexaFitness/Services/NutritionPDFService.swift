import UIKit
import PDFKit

enum NutritionPDFService {
    static func generateMealPlanPDF(
        meals: [MealEntry],
        goal: DailyNutritionGoal,
        startDate: Date,
        endDate: Date
    ) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 40
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = renderer.pdfData { context in
            let calendar = Calendar.current
            var currentDate = calendar.startOfDay(for: startDate)
            let end = calendar.startOfDay(for: endDate)

            context.beginPage()
            var yOffset: CGFloat = margin

            yOffset = drawHeader(in: context.cgContext, at: yOffset, width: contentWidth, margin: margin, start: startDate, end: endDate)
            yOffset = drawGoalSummary(in: context.cgContext, at: yOffset, width: contentWidth, margin: margin, goal: goal)

            while currentDate <= end {
                let dayMeals = meals.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
                    .sorted { $0.date < $1.date }

                let estimatedHeight = estimateDayHeight(dayMeals)
                if yOffset + estimatedHeight > pageHeight - margin {
                    context.beginPage()
                    yOffset = margin
                }

                yOffset = drawDaySection(
                    in: context.cgContext,
                    context: context,
                    at: yOffset,
                    width: contentWidth,
                    margin: margin,
                    pageHeight: pageHeight,
                    date: currentDate,
                    meals: dayMeals,
                    goal: goal
                )

                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(86400)
            }

            if yOffset + 40 > pageHeight - margin {
                context.beginPage()
                yOffset = margin
            }
            drawFooter(in: context.cgContext, at: yOffset, width: contentWidth, margin: margin)
        }

        return data
    }

    private static func drawHeader(in ctx: CGContext, at y: CGFloat, width: CGFloat, margin: CGFloat, start: Date, end: Date) -> CGFloat {
        var yPos = y

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let title = "Kynexa Nutrition Tracker"
        title.draw(at: CGPoint(x: margin, y: yPos), withAttributes: titleAttrs)
        yPos += 30

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let subtitle = "\(formatter.string(from: start)) — \(formatter.string(from: end))"
        subtitle.draw(at: CGPoint(x: margin, y: yPos), withAttributes: subtitleAttrs)
        yPos += 20

        ctx.setStrokeColor(UIColor.separator.cgColor)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: margin, y: yPos))
        ctx.addLine(to: CGPoint(x: margin + width, y: yPos))
        ctx.strokePath()
        yPos += 16

        return yPos
    }

    private static func drawGoalSummary(in ctx: CGContext, at y: CGFloat, width: CGFloat, margin: CGFloat, goal: DailyNutritionGoal) -> CGFloat {
        var yPos = y

        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: UIColor.secondaryLabel
        ]
        "DAILY GOALS".draw(at: CGPoint(x: margin, y: yPos), withAttributes: headerAttrs)
        yPos += 16

        let goalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.label
        ]
        let goalText = "Calories: \(goal.calories)  |  Protein: \(Int(goal.protein))g  |  Carbs: \(Int(goal.carbs))g  |  Fat: \(Int(goal.fat))g"
        goalText.draw(at: CGPoint(x: margin, y: yPos), withAttributes: goalAttrs)
        yPos += 24

        return yPos
    }

    private static func estimateDayHeight(_ meals: [MealEntry]) -> CGFloat {
        var h: CGFloat = 50
        if meals.isEmpty {
            h += 20
        } else {
            for meal in meals {
                h += 22
                h += CGFloat(meal.foods.count) * 16
                h += 10
            }
            h += 24
        }
        return h
    }

    private static func drawDaySection(
        in ctx: CGContext,
        context: UIGraphicsPDFRendererContext,
        at y: CGFloat,
        width: CGFloat,
        margin: CGFloat,
        pageHeight: CGFloat,
        date: Date,
        meals: [MealEntry],
        goal: DailyNutritionGoal
    ) -> CGFloat {
        var yPos = y

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        let dayString = formatter.string(from: date)

        let dayAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        dayString.draw(at: CGPoint(x: margin, y: yPos), withAttributes: dayAttrs)
        yPos += 22

        if meals.isEmpty {
            let emptyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.tertiaryLabel
            ]
            "No meals logged".draw(at: CGPoint(x: margin + 8, y: yPos), withAttributes: emptyAttrs)
            yPos += 20
        } else {
            for meal in meals {
                if yPos + 30 > pageHeight - margin {
                    context.beginPage()
                    yPos = margin
                }

                let mealHeaderAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                    .foregroundColor: UIColor.label
                ]
                let calAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10, weight: .medium),
                    .foregroundColor: UIColor.secondaryLabel
                ]

                meal.mealType.rawValue.draw(at: CGPoint(x: margin + 8, y: yPos), withAttributes: mealHeaderAttrs)
                let calText = "\(meal.totalNutrition.calories) cal"
                let calSize = calText.size(withAttributes: calAttrs)
                calText.draw(at: CGPoint(x: margin + width - calSize.width, y: yPos), withAttributes: calAttrs)
                yPos += 18

                let foodAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let macroAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 8, weight: .medium),
                    .foregroundColor: UIColor.tertiaryLabel
                ]

                for food in meal.foods {
                    if yPos + 16 > pageHeight - margin {
                        context.beginPage()
                        yPos = margin
                    }

                    let foodName = "  • \(food.name) (\(food.quantity))"
                    foodName.draw(at: CGPoint(x: margin + 12, y: yPos), withAttributes: foodAttrs)

                    var macros = "P:\(String(format: "%.0f", food.nutrition.protein))g C:\(String(format: "%.0f", food.nutrition.carbs))g F:\(String(format: "%.0f", food.nutrition.fat))g"
                    if food.nutrition.alcohol > 0 {
                        macros += " A:\(String(format: "%.0f", food.nutrition.alcohol))g"
                    }
                    let macroSize = macros.size(withAttributes: macroAttrs)
                    macros.draw(at: CGPoint(x: margin + width - macroSize.width, y: yPos + 1), withAttributes: macroAttrs)
                    yPos += 14
                }
                yPos += 6
            }

            let totalNutrition = NutritionInfo(
                calories: meals.map(\.totalNutrition.calories).reduce(0, +),
                protein: meals.map(\.totalNutrition.protein).reduce(0, +),
                carbs: meals.map(\.totalNutrition.carbs).reduce(0, +),
                fat: meals.map(\.totalNutrition.fat).reduce(0, +),
                fiber: meals.map(\.totalNutrition.fiber).reduce(0, +),
                sugar: meals.map(\.totalNutrition.sugar).reduce(0, +),
                alcohol: meals.map(\.totalNutrition.alcohol).reduce(0, +)
            )

            let totalAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            var totalText = "Day Total: \(totalNutrition.calories) cal  |  P: \(String(format: "%.0f", totalNutrition.protein))g  C: \(String(format: "%.0f", totalNutrition.carbs))g  F: \(String(format: "%.0f", totalNutrition.fat))g"
            if totalNutrition.alcohol > 0 {
                totalText += "  A: \(String(format: "%.0f", totalNutrition.alcohol))g"
            }
            totalText.draw(at: CGPoint(x: margin + 8, y: yPos), withAttributes: totalAttrs)
            yPos += 18
        }

        ctx.setStrokeColor(UIColor.separator.withAlphaComponent(0.3).cgColor)
        ctx.setLineWidth(0.5)
        ctx.move(to: CGPoint(x: margin, y: yPos))
        ctx.addLine(to: CGPoint(x: margin + width, y: yPos))
        ctx.strokePath()
        yPos += 12

        return yPos
    }

    private static func drawFooter(in ctx: CGContext, at y: CGFloat, width: CGFloat, margin: CGFloat) {
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .regular),
            .foregroundColor: UIColor.tertiaryLabel
        ]
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let footerText = "Generated by Kynexa Fitness on \(formatter.string(from: .now))"
        let size = footerText.size(withAttributes: footerAttrs)
        footerText.draw(at: CGPoint(x: margin + (width - size.width) / 2, y: y + 10), withAttributes: footerAttrs)
    }
}
