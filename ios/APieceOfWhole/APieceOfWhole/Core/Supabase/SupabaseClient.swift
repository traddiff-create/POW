import Foundation
import Supabase

extension SupabaseClient {
    static let shared: SupabaseClient = {
        guard let supabaseURL = Config.supabaseURL,
              let supabaseAnonKey = Config.supabaseAnonKey else {
            let placeholderURL = URL(string: "https://missing-supabase-configuration.invalid") ?? URL(fileURLWithPath: "/")
            return SupabaseClient(supabaseURL: placeholderURL, supabaseKey: "missing-configuration")
        }

        return SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseAnonKey)
    }()
}
