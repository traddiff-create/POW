import Foundation

enum AppConfigurationError: LocalizedError, Equatable {
    case missingSupabaseURL
    case invalidSupabaseURL
    case missingSupabaseAnonKey

    var errorDescription: String? {
        switch self {
        case .missingSupabaseURL:
            return "SUPABASE_URL is missing from the app configuration."
        case .invalidSupabaseURL:
            return "SUPABASE_URL is not a valid URL."
        case .missingSupabaseAnonKey:
            return "SUPABASE_ANON_KEY is missing from the app configuration."
        }
    }
}

enum Config {
    static var supabaseURL: URL? {
        guard let raw = infoValue("SUPABASE_URL") else {
            return nil
        }
        return URL(string: raw)
    }

    static var supabaseAnonKey: String? {
        infoValue("SUPABASE_ANON_KEY")
    }

    static var supabaseConfigurationError: AppConfigurationError? {
        guard let rawURL = infoValue("SUPABASE_URL") else {
            return .missingSupabaseURL
        }
        guard URL(string: rawURL) != nil else {
            return .invalidSupabaseURL
        }
        guard infoValue("SUPABASE_ANON_KEY") != nil else {
            return .missingSupabaseAnonKey
        }
        return nil
    }

    static let appURL = URL(string: "https://apieceofwhole.com") ?? URL(fileURLWithPath: "/")
    static let supportEmail = "hello@apieceofwhole.com"
    static let storeKitProductID = "apow.cohort.8week"
    static let audioStorageBucket = "practice-audio"

    private static func infoValue(_ key: String) -> String? {
        guard let value = Bundle.main.infoDictionary?[key] as? String else {
            return nil
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
