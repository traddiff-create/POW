import Foundation

enum Config {
    static let supabaseURL: URL = {
        guard let raw = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
              !raw.isEmpty,
              let url = URL(string: raw) else {
            fatalError("SUPABASE_URL missing from Info.plist — check Secrets.xcconfig")
        }
        return url
    }()

    static let supabaseAnonKey: String = {
        guard let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
              !key.isEmpty else {
            fatalError("SUPABASE_ANON_KEY missing from Info.plist — check Secrets.xcconfig")
        }
        return key
    }()

    static let appURL = URL(string: "https://apieceofwhole.com")!
    static let supportEmail = "hello@apieceofwhole.com"
    static let storeKitProductID = "apow.cohort.8week"
    static let audioStorageBucket = "practice-audio"
}
