import SwiftUI

struct DAForm705ExportView: View {
    @Environment(\.dismiss) private var dismiss
    let result: AFTCalculatorResult

    @State private var exportData: DAForm705ExportData
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @State private var isGenerating = false

    init(result: AFTCalculatorResult) {
        self.result = result
        self._exportData = State(initialValue: DAForm705ExportData(from: result))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerCard
                        athleteInfoSection
                        testInfoSection
                        scoresSummary
                        exportButton
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Score Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "doc.richtext.fill")
                    .foregroundStyle(KinexaTheme.accent)
                Text("Export Score Report")
                    .font(.headline)
                    .foregroundStyle(KinexaTheme.primaryText)
            }

            Text("Generates a score report with your fitness test data filled in. Review and add optional details before exporting.")
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.secondaryText)

            Text("For personal reference only.")
                .font(.caption2)
                .foregroundStyle(KinexaTheme.warning)
                .padding(.top, 2)
        }
        .padding(18)
        .premiumCard()
    }

    private var athleteInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("ATHLETE INFORMATION")

            fieldRow(label: "Name", text: $exportData.athleteName, placeholder: "Last, First MI")

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Age")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Text("\(exportData.age)")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Sex")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Text(exportData.sex.rawValue)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var testInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("TEST INFORMATION")

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Type")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    Text("Example Score")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Standard")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    Text(exportData.standard.rawValue)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Date")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.secondaryText)

                Text(exportData.testDate.formatted(date: .long, time: .omitted))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var scoresSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("EVENT SCORES")

            eventRow(abbr: "MDL", name: "3RM Deadlift", raw: "\(exportData.deadliftLbs) lbs", points: exportData.deadliftPoints)
            eventRow(abbr: "HRP", name: "Hand-Release Push-Up", raw: "\(exportData.pushUpReps) reps", points: exportData.pushUpPoints)
            eventRow(abbr: "SDC", name: "Sprint-Drag-Carry", raw: AFTCalculatorService.formatTime(exportData.sdcSeconds), points: exportData.sdcPoints)
            eventRow(abbr: "PLK", name: "Plank", raw: AFTCalculatorService.formatTime(exportData.plankSeconds), points: exportData.plankPoints)
            eventRow(abbr: "2MR", name: "2-Mile Run", raw: AFTCalculatorService.formatTime(exportData.runSeconds), points: exportData.runPoints)

            Divider().overlay(KinexaTheme.border)

            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
                Text("\(exportData.totalScore) / 500")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
            }

            HStack(spacing: 6) {
                Image(systemName: exportData.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.subheadline)
                Text(exportData.passed ? "PASS" : "NO GO")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(exportData.passed ? KinexaTheme.success : KinexaTheme.danger)
        }
        .padding(18)
        .premiumCard()
    }

    private var exportButton: some View {
        Button {
            generateAndShare()
        } label: {
            HStack(spacing: 10) {
                if isGenerating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text(isGenerating ? "Generating..." : "Export Score Report")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(KinexaTheme.heroGradient)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: KinexaTheme.accent.opacity(0.28), radius: 18, y: 10)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(isGenerating)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(KinexaTheme.accent)
            .tracking(0.5)
    }

    private func fieldRow(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(KinexaTheme.secondaryText)

            TextField(placeholder, text: text)
                .font(.body)
                .foregroundStyle(KinexaTheme.primaryText)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(KinexaTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10).stroke(KinexaTheme.border)
                }
        }
    }

    private func eventRow(abbr: String, name: String, raw: String, points: Int) -> some View {
        HStack {
            Text(abbr)
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.accent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(raw)
                    .font(.caption)
                    .foregroundStyle(KinexaTheme.secondaryText)
            }

            Spacer()

            Text("\(points)")
                .font(.title3.weight(.bold))
                .foregroundStyle(pillColor(points))
        }
        .padding(.vertical, 4)
    }

    private func pillColor(_ value: Int) -> Color {
        if value >= 80 { return KinexaTheme.success }
        if value >= 60 { return KinexaTheme.accent }
        if value >= 40 { return KinexaTheme.warning }
        return KinexaTheme.danger
    }

    private func generateAndShare() {
        isGenerating = true
        Task {
            guard let pdfData = DAForm705PDFService.generatePDF(from: exportData),
                  let url = DAForm705PDFService.savePDFToTemp(data: pdfData, athleteName: exportData.athleteName) else {
                isGenerating = false
                return
            }
            pdfURL = url
            showShareSheet = true
            isGenerating = false
        }
    }
}

