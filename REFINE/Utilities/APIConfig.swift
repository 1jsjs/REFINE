import Foundation

struct APIConfig {
    // Cloudflare Workers를 사용하므로 API 키는 서버에서 관리
    // iOS 앱에서는 API Base URL만 필요
    static var apiBaseURL: String {
        // Info.plist에서 APIBaseURL 읽기
        if let baseURL = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
           !baseURL.isEmpty {
            print("✅ Found API Base URL in Info.plist: \(baseURL)")
            return baseURL
        }
        
        // Fallback to Cloudflare Workers URL
        let defaultURL = "https://rapid-sound-ba4c.pjs020201.workers.dev"
        print("⚠️ Using default Cloudflare Workers URL: \(defaultURL)")
        return defaultURL
    }
    
    static var isConfigured: Bool {
        return !apiBaseURL.isEmpty
    }
}
