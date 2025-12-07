import Foundation

struct OpenAIService {
    // Cloudflare Workers 엔드포인트 (API 키는 서버에서 관리)
    private let endpoint: String
    private let requestTimeout: TimeInterval = 30

    init() {
        // APIConfig에서 Cloudflare Workers URL 가져오기
        self.endpoint = APIConfig.apiBaseURL
    }

    func analyzeEntries(_ entries: [DailyEntry]) async throws -> AnalysisResult {
        // 엔드포인트 확인
        guard !endpoint.isEmpty else {
            print("⚠️ API endpoint missing, using dummy data for testing")
            // Wait a bit to simulate API call
            try await Task.sleep(nanoseconds: 2_000_000_000)
            return AnalysisResult(
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
        다음은 사용자가 \(entryCount)개의 조각으로 작성한 기록입니다. 이를 분석하여 다음을 제공해주세요:

        1. 핵심 키워드 2-3개 (해시태그 형식, 예: #집요함, #성장)
        2. 전체적인 요약 (2-3문장)
        3. 자기소개서에 사용할 수 있는 한 줄 설명 (1문장)

        응답은 반드시 다음 JSON 형식으로만 작성해주세요:
        {
          "keywords": ["#키워드1", "#키워드2"],
          "summary": "요약 문장들...",
          "oneLiner": "자소서용 한 줄..."
        }

        \(entryCount)개 조각의 기록:
        \(combinedText)
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
            throw OpenAIError.noContent
        }

        print("[Cloudflare Workers] Message content length: \(content.count)")

        return try parseAnalysisResult(from: content)
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

    private func parseAnalysisResult(from content: String) throws -> AnalysisResult {
        // Try to extract JSON from code blocks or plain text
        let source = content.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1) Prefer fenced code blocks with json
        if let range = source.range(of: "```json") {
            let after = source[range.upperBound...]
            if let end = after.range(of: "```") {
                let json = after[..<end.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
                if let data = json.data(using: .utf8) {
                    do { return try JSONDecoder().decode(AnalysisResult.self, from: data) } catch {
                        print("[Cloudflare Workers] JSON decode failed from json block: \(error)")
                    }
                }
            }
        }

        // 2) Any fenced code block
        if let start = source.range(of: "```") {
            let after = source[start.upperBound...]
            if let end = after.range(of: "```") {
                let json = after[..<end.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
                if let data = json.data(using: .utf8) {
                    do { return try JSONDecoder().decode(AnalysisResult.self, from: data) } catch {
                        print("[Cloudflare Workers] JSON decode failed from generic block: \(error)")
                    }
                }
            }
        }

        // 3) Heuristic: find first top-level JSON object substring
        if let obj = Self.firstJSONObject(in: source) {
            if let data = obj.data(using: .utf8) {
                do { return try JSONDecoder().decode(AnalysisResult.self, from: data) } catch {
                    print("[Cloudflare Workers] JSON decode failed from heuristic object: \(error)\nObject: \(obj)")
                }
            }
        }

        // 4) Last attempt: treat entire content as JSON
        if let data = source.data(using: .utf8) {
            do { return try JSONDecoder().decode(AnalysisResult.self, from: data) } catch {
                print("[Cloudflare Workers] Final JSON decode failed: \(error)\nContent: \(source)")
            }
        }

        throw OpenAIError.invalidJSON
    }

    private static func firstJSONObject(in text: String) -> String? {
        var depth = 0
        var startIndex: String.Index?
        var i = text.startIndex
        while i < text.endIndex {
            let ch = text[i]
            if ch == "{" {
                if depth == 0 { startIndex = i }
                depth += 1
            } else if ch == "}" {
                if depth > 0 { depth -= 1 }
                if depth == 0, let s = startIndex {
                    return String(text[s...i])
                }
            }
            i = text.index(after: i)
        }
        return nil
    }
}

struct AnalysisResult: Codable {
    let keywords: [String]
    let summary: String
    let oneLiner: String
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
    case missingEndpoint
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case noContent
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .missingEndpoint:
            return "API 엔드포인트가 설정되지 않았습니다. Info.plist에서 APIBaseURL을 확인해주세요."
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .invalidResponse:
            return "유효하지 않은 응답입니다."
        case .httpError(let statusCode):
            return "HTTP 오류: \(statusCode)"
        case .noContent:
            return "응답 내용이 없습니다."
        case .invalidJSON:
            return "JSON 파싱에 실패했습니다."
        }
    }
}
