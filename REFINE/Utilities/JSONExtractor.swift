import Foundation

enum JSONExtractor {
    static func extractFirstJSONObject(from text: String) -> String? {
        // 1) Remove code fences (rough approach)
        let stripped = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 2) Find first '{' and match balanced '}'
        guard let start = stripped.firstIndex(of: "{") else { return nil }

        var depth = 0
        var inString = false
        var escape = false
        var endIndex: String.Index? = nil

        var i = start
        while i < stripped.endIndex {
            let ch = stripped[i]

            if escape {
                escape = false
            } else if ch == "\\" {
                escape = true
            } else if ch == "\"" {
                inString.toggle()
            } else if !inString {
                if ch == "{" { depth += 1 }
                if ch == "}" {
                    depth -= 1
                    if depth == 0 {
                        endIndex = i
                        break
                    }
                }
            }
            i = stripped.index(after: i)
        }

        guard let end = endIndex else { return nil }
        return String(stripped[start...end])
    }
}
