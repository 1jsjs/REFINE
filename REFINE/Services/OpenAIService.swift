import Foundation

struct RefineAIResponse: Codable {
    let tone: String
    let keywords: [String]
    let summary: String
    let oneLiner: String
}

enum OpenAIServiceError: Error {
    case invalidURL
    case badResponse
    case emptyBody
    case jsonNotFound
    case decodeFailed
}

struct OpenAIService {
    // Cloudflare Workers 엔드포인트 (API 키는 서버에서 관리)
    private let endpoint: String
    private let requestTimeout: TimeInterval = 30

    init() {
        // APIConfig에서 Cloudflare Workers URL 가져오기
        self.endpoint = APIConfig.apiBaseURL
    }

    func analyzeEntries(_ entries: [DailyEntry]) async throws -> RefineAIResponse {
        // 엔드포인트 확인
        guard !endpoint.isEmpty else {
            print("⚠️ API endpoint missing, using dummy data for testing")
            // Wait a bit to simulate API call
            try await Task.sleep(nanoseconds: 2_000_000_000)
            return RefineAIResponse(
                tone: "growth",
                keywords: ["#성장", "#도전", "#열정"],
                summary: "이번 주는 새로운 도전과 배움의 연속이었습니다. 어려움 속에서도 포기하지 않고 계속 앞으로 나아가는 모습이 인상적이었습니다.",
                oneLiner: "실패를 두려워하지 않고 끊임없이 도전하며 성장하는 사람"
            )
        }

        // Combine all entries into a single text
        let combinedText = entries
            .sorted { $0.pieceNumber < $1.pieceNumber }
            .enumerated()
            .map { index, entry in
                "Day \(entry.pieceNumber): \(entry.text)"
            }
            .joined(separator: "\n\n")

        let entryCount = entries.count
        let prompt = """
        You are a JSON-only assistant.
        Return ONLY a single valid JSON object.
        Do not wrap it in markdown.
        Do not include any extra text.

        Schema:
        {
          "tone": "calm|growth|challenge|joy|reflection|neutral",
          "keywords": [string, string, string, string, string],
          "summary": string,
          "oneLiner": string
        }

        Rules:
        - tone: Choose ONE that best represents the overall emotional tone (calm, growth, challenge, joy, reflection, neutral)
        - keywords: 3~7 Korean hashtag items (e.g., #성장, #도전)
        - summary: 2~4 sentences in Korean
        - oneLiner: One sentence in Korean, no quotes, suitable for job application essays

        Analyze the user's journal entries for this cycle and produce the JSON result.

        Entries:
        \(combinedText)

        Return JSON only.
        """

        let request = try createRequest(prompt: prompt)
        print("[Cloudflare Workers] Requesting with prompt length: \(prompt.count) chars")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("[Cloudflare Workers] HTTP Status: \(httpResponse.statusCode)")
        }
        let rawString = String(data: data, encoding: .utf8) ?? "<non-utf8>"
        print("[Cloudflare Workers] Raw response preview: \(rawString.prefix(400))")

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("[Cloudflare Workers] HTTP Error Body: \(body)")
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode)
        }

        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = result.choices.first?.message.content else {
            throw OpenAIServiceError.emptyBody
        }

        print("[Cloudflare Workers] Message content length: \(content.count)")

        return try parseRefineAIResponse(from: content)
    }

    private func createRequest(prompt: String) throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw OpenAIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Cloudflare Workers로 요청하므로 Authorization 헤더 불필요
        // API 키는 Cloudflare Workers Secret에서 관리
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "openai/gpt-4o-mini",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = requestTimeout
        print("[Cloudflare Workers] Request body bytes: \(request.httpBody?.count ?? 0)")
        return request
    }

    private func parseRefineAIResponse(from content: String) throws -> RefineAIResponse {
        // Use JSONExtractor utility
        guard let jsonString = JSONExtractor.extractFirstJSONObject(from: content) else {
            print("[Cloudflare Workers] No JSON object found in content: \(content.prefix(200))")
            throw OpenAIServiceError.jsonNotFound
        }

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw OpenAIServiceError.decodeFailed
        }

        do {
            let decoded = try JSONDecoder().decode(RefineAIResponse.self, from: jsonData)
            print("[Cloudflare Workers] Successfully decoded: tone=\(decoded.tone), keywords=\(decoded.keywords)")
            return decoded
        } catch {
            print("[Cloudflare Workers] JSON decode failed: \(error)\nJSON: \(jsonString)")
            throw OpenAIServiceError.decodeFailed
        }
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}

enum OpenAIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .invalidResponse:
            return "유효하지 않은 응답입니다."
        case .httpError(let statusCode):
            return "HTTP 오류: \(statusCode)"
        }
    }
}
