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

    func restoreSession() async throws -> Session? {
        session = try await client.auth.session
        return session
    }

    func createAccount(email: String, password: String) async throws -> SignUpOutcome {
        let response = try await client.auth.signUp(email: email, password: password)
        session = response.session
        return SignUpOutcome(user: response.user, session: response.session)
    }

    func signUp(email: String, password: String) async throws -> User {
        try await createAccount(email: email, password: password).user
    }

    func signIn(email: String, password: String) async throws -> Session {
        let s = try await client.auth.signIn(email: email, password: password)
        session = s
        return s
    }

    func signInAnonymously() async throws -> Session {
        let s = try await client.auth.signInAnonymously()
        session = s
        return s
    }

    func upgradeAnonymousAccount(email: String, password: String) async throws -> User {
        try await client.auth.update(user: UserAttributes(email: email, password: password))
    }

    func signInWithApple(identityToken: String, rawNonce: String) async throws -> Session {
        let credentials = OpenIDConnectCredentials(
            provider: .apple,
            idToken: identityToken,
            nonce: rawNonce
        )
        let s = try await client.auth.signInWithIdToken(credentials: credentials)
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
    var isAnonymous: Bool { currentUser?.isAnonymous == true }
}

extension AuthService: AuthProviding {}
