import UIKit
import PDFKit

enum DailyJournalPDFService {
    static func generateDayPDF(
        date: Date,
        workouts: [CompletedWorkoutRecord],
        cardioSessions: [CardioSession],
        quickStartRecords: [QuickStartRecord],
        meals: [MealEntry],
        nutrition: NutritionInfo,
        nutritionGoal: DailyNutritionGoal,
        waterOunces: Double,
        steps: Int
    ) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 40
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = margin

            y = drawTitle(at: y, width: contentWidth, margin: margin, date: date, ctx: context.cgContext)
            y = drawStatsBar(at: y, width: contentWidth, margin: margin, workoutCount: workouts.count + cardioSessions.count + quickStartRecords.count, calories: nutrition.calories, steps: steps, water: waterOunces, ctx: context.cgContext)

            if !workouts.isEmpty || !cardioSessions.isEmpty || !quickStartRecords.isEmpty {
                y = drawSectionHeader("WORKOUTS", at: y, margin: margin, ctx: context.cgContext)

                for record in workouts {
                    if y + 80 > pageHeight - margin { context.beginPage(); y = margin }
                    y = drawWorkoutRecord(record, at: y, width: contentWidth, margin: margin, ctx: context.cgContext)
                }

                for session in cardioSessions {
                    if y + 40 > pageHeight - margin { context.beginPage(); y = margin }
                    y = drawCardioSession(session, at: y, width: contentWidth, margin: margin, ctx: context.cgContext)
                }

                for qs in quickStartRecords {
                    if y + 40 > pageHeight - margin { context.beginPage(); y = margin }
                    y = drawQuickStart(qs, at: y, width: contentWidth, margin: margin, ctx: context.cgContext)
                }
            } else {
                y = drawSectionHeader("WORKOUTS", at: y, margin: margin, ctx: context.cgContext)
                y = drawEmptyNote("No workouts logged", at: y, margin: margin)
            }

            y += 8

            y = drawSectionHeader("NUTRITION", at: y, margin: margin, ctx: context.cgContext)

            if y + 60 > pageHeight - margin { context.beginPage(); y = margin }
            y = drawNutritionSummary(nutrition: nutrition, goal: nutritionGoal, at: y, width: contentWidth, margin: margin, ctx: context.cgContext)

            if !meals.isEmpty {
                for meal in meals {
                    if y + 50 > pageHeight - margin { context.beginPage(); y = margin }
                    y = drawMealEntry(meal, at: y, width: contentWidth, margin: margin, ctx: context.cgContext, pageHeight: pageHeight, context: context)
                }
            } else {
                y = drawEmptyNote("No meals logged", at: y, margin: margin)
            }

            if y + 40 > pageHeight - margin { context.beginPage(); y = margin }
            drawFooter(at: max(y + 20, pageHeight - margin - 20), width: contentWidth, margin: margin, ctx: context.cgContext)
        }

        return data
    }

    private static func drawTitle(at y: CGFloat, width: CGFloat, margin: CGFloat, date: Date, ctx: CGContext) -> CGFloat {
        var yPos = y

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        "Daily Activity Report".draw(at: CGPoint(x: margin, y: yPos), withAttributes: titleAttrs)
        yPos += 32

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        let dateStr = formatter.string(from: date)
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        dateStr.draw(at: CGPoint(x: margin, y: yPos), withAttributes: dateAttrs)
        yPos += 22

        ctx.setStrokeColor(UIColor.separator.cgColor)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: margin, y: yPos))
        ctx.addLine(to: CGPoint(x: margin + width, y: yPos))
        ctx.strokePath()
        yPos += 16

        return yPos
    }

    private static func drawStatsBar(at y: CGFloat, width: CGFloat, margin: CGFloat, workoutCount: Int, calories: Int, steps: Int, water: Double, ctx: CGContext) -> CGFloat {
        var yPos = y

        let boxWidth = width / 4
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]

        let stats: [(String, String)] = [
            ("\(workoutCount)", "Workouts"),
            ("\(calories)", "Calories"),
            ("\(steps)", "Steps"),
            ("\(Int(water))oz", "Water")
        ]

        for (i, stat) in stats.enumerated() {
            let x = margin + boxWidth * CGFloat(i)
            let valSize = stat.0.size(withAttributes: valueAttrs)
            let lblSize = stat.1.size(withAttributes: labelAttrs)
            let centerX = x + (boxWidth - valSize.width) / 2
            let lblCenterX = x + (boxWidth - lblSize.width) / 2
            stat.0.draw(at: CGPoint(x: centerX, y: yPos), withAttributes: valueAttrs)
            stat.1.draw(at: CGPoint(x: lblCenterX, y: yPos + 22), withAttributes: labelAttrs)
        }
        yPos += 46

        ctx.setStrokeColor(UIColor.separator.withAlphaComponent(0.3).cgColor)
        ctx.setLineWidth(0.5)
        ctx.move(to: CGPoint(x: margin, y: yPos))
        ctx.addLine(to: CGPoint(x: margin + width, y: yPos))
        ctx.strokePath()
        yPos += 16

        return yPos
    }

    private static func drawSectionHeader(_ title: String, at y: CGFloat, margin: CGFloat, ctx: CGContext) -> CGFloat {
        var yPos = y
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .heavy),
            .foregroundColor: UIColor.secondaryLabel
        ]
        title.draw(at: CGPoint(x: margin, y: yPos), withAttributes: attrs)
        yPos += 22
        return yPos
    }

    private static func drawWorkoutRecord(_ record: CompletedWorkoutRecord, at y: CGFloat, width: CGFloat, margin: CGFloat, ctx: CGContext) -> CGFloat {
        var yPos = y

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let detailAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let exerciseAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]

        let timeF = DateFormatter()
        timeF.dateFormat = "h:mm a"

        "✓ \(record.title)".draw(at: CGPoint(x: margin + 4, y: yPos), withAttributes: titleAttrs)
        let timeStr = timeF.string(from: record.date)
        let timeSize = timeStr.size(withAttributes: detailAttrs)
        timeStr.draw(at: CGPoint(x: margin + width - timeSize.width, y: yPos + 2), withAttributes: detailAttrs)
        yPos += 18

        "\(record.exerciseCount) exercises · \(record.source.rawValue)".draw(at: CGPoint(x: margin + 8, y: yPos), withAttributes: detailAttrs)
        yPos += 16

        for exercise in record.exercises.prefix(8) {
            let completed = exercise.isCompleted ? "✓" : "○"
            "\(completed) \(exercise.name) — \(exercise.displayDetail)".draw(at: CGPoint(x: margin + 12, y: yPos), withAttributes: exerciseAttrs)
            yPos += 13
        }

        if record.exercises.count > 8 {
            "+\(record.exercises.count - 8) more exercises".draw(at: CGPoint(x: margin + 12, y: yPos), withAttributes: exerciseAttrs)
            yPos += 13
        }

        yPos += 8
        return yPos
    }

    private static func drawCardioSession(_ session: CardioSession, at y: CGFloat, width: CGFloat, margin: CGFloat, ctx: CGContext) -> CGFloat {
        var yPos = y

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let detailAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]

        "♥ \(session.workoutName)".draw(at: CGPoint(x: margin + 4, y: yPos), withAttributes: titleAttrs)
        yPos += 18

        var details: [String] = ["\(session.durationMinutes) min"]
        if let dist = session.distanceMiles, dist > 0 { details.append(String(format: "%.1f mi", dist)) }
        if let cal = session.caloriesBurned { details.append("\(cal) cal") }
        details.joined(separator: " · ").draw(at: CGPoint(x: margin + 8, y: yPos), withAttributes: detailAttrs)
        yPos += 20

        return yPos
    }

    private static func drawQuickStart(_ qs: QuickStartRecord, at y: CGFloat, width: CGFloat, margin: CGFloat, ctx: CGContext) -> CGFloat {
        var yPos = y

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let detailAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]

        "⚡ \(qs.activity.rawValue)".draw(at: CGPoint(x: margin + 4, y: yPos), withAttributes: titleAttrs)
        yPos += 18

        var details = [qs.formattedDuration]
        if qs.activity.usesGPS { details.append(qs.formattedDistance); details.append(qs.formattedPace) }
        details.joined(separator: " · ").draw(at: CGPoint(x: margin + 8, y: yPos), withAttributes: detailAttrs)
        yPos += 20

        return yPos
    }

    private static func drawNutritionSummary(nutrition: NutritionInfo, goal: DailyNutritionGoal, at y: CGFloat, width: CGFloat, margin: CGFloat, ctx: CGContext) -> CGFloat {
        var yPos = y

        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let valAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]

        "Daily Totals vs Goals".draw(at: CGPoint(x: margin + 4, y: yPos), withAttributes: headerAttrs)
        yPos += 18

        let lines = [
            "Calories: \(nutrition.calories) / \(goal.calories)",
            "Protein: \(Int(nutrition.protein))g / \(Int(goal.protein))g",
            "Carbs: \(Int(nutrition.carbs))g / \(Int(goal.carbs))g",
            "Fat: \(Int(nutrition.fat))g / \(Int(goal.fat))g",
            "Fiber: \(Int(nutrition.fiber))g  |  Sugar: \(Int(nutrition.sugar))g"
        ]

        for line in lines {
            line.draw(at: CGPoint(x: margin + 8, y: yPos), withAttributes: valAttrs)
            yPos += 14
        }
        yPos += 8

        return yPos
    }

    private static func drawMealEntry(_ meal: MealEntry, at y: CGFloat, width: CGFloat, margin: CGFloat, ctx: CGContext, pageHeight: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        var yPos = y

        let mealAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        let calAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let foodAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]

        meal.mealType.rawValue.draw(at: CGPoint(x: margin + 8, y: yPos), withAttributes: mealAttrs)
        let calText = "\(meal.totalNutrition.calories) cal"
        let calSize = calText.size(withAttributes: calAttrs)
        calText.draw(at: CGPoint(x: margin + width - calSize.width, y: yPos), withAttributes: calAttrs)
        yPos += 16

        for food in meal.foods {
            if yPos + 14 > pageHeight - margin { context.beginPage(); yPos = margin }
            "  • \(food.name) (\(food.quantity)) — P:\(Int(food.nutrition.protein))g C:\(Int(food.nutrition.carbs))g F:\(Int(food.nutrition.fat))g".draw(at: CGPoint(x: margin + 12, y: yPos), withAttributes: foodAttrs)
            yPos += 13
        }
        yPos += 6

        return yPos
    }

    private static func drawEmptyNote(_ text: String, at y: CGFloat, margin: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor.tertiaryLabel
        ]
        text.draw(at: CGPoint(x: margin + 8, y: y), withAttributes: attrs)
        return y + 20
    }

    private static func drawFooter(at y: CGFloat, width: CGFloat, margin: CGFloat, ctx: CGContext) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .regular),
            .foregroundColor: UIColor.tertiaryLabel
        ]
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let text = "Generated by Kynexa Fitness on \(formatter.string(from: .now))"
        let size = text.size(withAttributes: attrs)
        text.draw(at: CGPoint(x: margin + (width - size.width) / 2, y: y), withAttributes: attrs)
    }
}
