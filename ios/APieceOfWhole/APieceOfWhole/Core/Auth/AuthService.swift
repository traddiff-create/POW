import Foundation
import Supabase

@Observable
@MainActor
final class AuthService {
    static let shared = AuthService()
    private let client = SupabaseClient.shared

    var session: Session?
    var isLoading = false
    var error: String?

    private init() {}

    func restoreSession() async {
        session = try? await client.auth.session
    }

    func signUp(email: String, password: String) async throws -> User {
        let response = try await client.auth.signUp(email: email, password: password)
        session = response.session
        return response.user
    }

    func signIn(email: String, password: String) async throws -> Session {
        let s = try await client.auth.signIn(email: email, password: password)
        session = s
        return s
    }

    func signOut() async throws {
        try await client.auth.signOut()
        session = nil
    }

    var currentUser: User? { session?.user }
    var userID: String? { currentUser?.id.uuidString }
    var userEmail: String? { currentUser?.email }
    var isSignedIn: Bool { session != nil }
}
