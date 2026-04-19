#if DEBUG
import SwiftUI

struct GeminiDiagnosticSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var keyResult: DiagnosticResult?
    @State private var textResult: DiagnosticResult?
    @State private var visionResult: DiagnosticResult?
    @State private var isRunning: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    resultCard(
                        title: "1. API Key Check",
                        subtitle: "Is EXPO_PUBLIC_GEMINI_API_KEY present?",
                        result: keyResult
                    )

                    resultCard(
                        title: "2. Text-only Ping",
                        subtitle: "gemini-2.5-flash · generateContent",
                        result: textResult
                    )

                    resultCard(
                        title: "3. Vision Ping (1×1 PNG)",
                        subtitle: "gemini-2.5-flash · image input",
                        result: visionResult
                    )

                    Button {
                        Task { await runAll() }
                    } label: {
                        HStack {
                            if isRunning {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "play.fill")
                            }
                            Text(isRunning ? "Running…" : "Run Diagnostic")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .disabled(isRunning)
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .navigationTitle("Gemini Diagnostic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task { await runAll() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("DEBUG ONLY")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(.orange)
            Text("Tests each stage of the Gemini pipeline so we can pinpoint where it breaks.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func resultCard(title: String, subtitle: String, result: DiagnosticResult?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                statusIcon(result)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.bold))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if let result, let status = result.status {
                    Text("HTTP \(status)")
                        .font(.caption.monospaced().weight(.semibold))
                        .foregroundStyle(result.isSuccess ? .green : .red)
                }
            }

            if let result {
                Text(result.body)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 8))
                    .textSelection(.enabled)
            } else {
                Text("Pending…")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
    }

    private func statusIcon(_ result: DiagnosticResult?) -> some View {
        Group {
            if let result {
                Image(systemName: result.isSuccess ? "checkmark.circle.fill" : "xmark.octagon.fill")
                    .foregroundStyle(result.isSuccess ? .green : .red)
            } else {
                Image(systemName: "circle.dotted")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.title3)
    }

    // MARK: - Checks

    private func runAll() async {
        guard !isRunning else { return }
        isRunning = true
        keyResult = nil
        textResult = nil
        visionResult = nil

        keyResult = checkKey()
        guard keyResult?.isSuccess == true else {
            isRunning = false
            return
        }

        textResult = await pingText()
        visionResult = await pingVision()
        isRunning = false
    }

    private func checkKey() -> DiagnosticResult {
        let key = Config.EXPO_PUBLIC_GEMINI_API_KEY
        if key.isEmpty {
            return DiagnosticResult(isSuccess: false, status: nil, body: "❌ Key is empty. EXPO_PUBLIC_GEMINI_API_KEY is not set or not injected into Config.swift.")
        }
        let prefix = String(key.prefix(6))
        return DiagnosticResult(
            isSuccess: true,
            status: nil,
            body: "✅ Key present.\nLength: \(key.count) chars\nPrefix: \(prefix)…"
        )
    }

    private func pingText() async -> DiagnosticResult {
        let body: [String: Any] = [
            "contents": [[
                "parts": [["text": "Say hi in one word."]]
            ]]
        ]
        return await postJSON(body: body)
    }

    private func pingVision() async -> DiagnosticResult {
        // 1x1 transparent PNG
        let pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkAAIAAAoAAv/lxKUAAAAASUVORK5CYII="
        let body: [String: Any] = [
            "contents": [[
                "parts": [
                    ["text": "What do you see?"],
                    ["inline_data": ["mime_type": "image/png", "data": pngBase64]]
                ]
            ]]
        ]
        return await postJSON(body: body)
    }

    private func postJSON(body: [String: Any]) async -> DiagnosticResult {
        let key = Config.EXPO_PUBLIC_GEMINI_API_KEY
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(key)"
        guard let url = URL(string: urlString) else {
            return DiagnosticResult(isSuccess: false, status: nil, body: "Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            let text = String(data: data, encoding: .utf8) ?? "<non-utf8 response>"
            let truncated = text.count > 1200 ? String(text.prefix(1200)) + "\n…(truncated)" : text
            return DiagnosticResult(
                isSuccess: (200...299).contains(status),
                status: status,
                body: truncated
            )
        } catch {
            return DiagnosticResult(isSuccess: false, status: nil, body: "Network error: \(error.localizedDescription)")
        }
    }
}

private struct DiagnosticResult {
    let isSuccess: Bool
    let status: Int?
    let body: String
}

#Preview {
    GeminiDiagnosticSheet()
}
#endif
