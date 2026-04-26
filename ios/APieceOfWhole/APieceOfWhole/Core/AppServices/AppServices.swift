import Foundation
import Supabase

struct SignUpOutcome: Sendable {
    let user: User
    let session: Session?
}

enum AccountCreationResult: Equatable, Sendable {
    case signedIn
    case emailConfirmationRequired(String)
}

enum AuthInputError: LocalizedError, Equatable {
    case emailRequired
    case passwordRequired
    case passwordMismatch
    case invalidCredentials
    case emailAlreadyExists

    var errorDescription: String? {
        switch self {
        case .emailRequired:
            return "Enter your email address."
        case .passwordRequired:
            return "Enter your password."
        case .passwordMismatch:
            return "Passwords do not match."
        case .invalidCredentials:
            return "Email or password is incorrect."
        case .emailAlreadyExists:
            return "An account already exists for this email. Sign in with this email instead."
        }
    }
}

enum AppDataError: LocalizedError {
    case missingSession
    case missingProfile
    case simulatedFailure

    var errorDescription: String? {
        switch self {
        case .missingSession:
            return "Could not find your user session. Please sign in again."
        case .missingProfile:
            return "Could not load your profile. Please try again."
        case .simulatedFailure:
            return "Simulated save failure. Please try again."
        }
    }
}

@MainActor
protocol AuthProviding: AnyObject {
    func restoreSession() async throws -> Session?
    func createAccount(email: String, password: String) async throws -> SignUpOutcome
    func signIn(email: String, password: String) async throws -> Session
    func signInAnonymously() async throws -> Session
    func upgradeAnonymousAccount(email: String, password: String) async throws -> User
    func signInWithApple(identityToken: String, rawNonce: String) async throws -> Session
    func signOut() async throws
}

@MainActor
protocol AppDataProviding: AnyObject {
    func fetchProfile(userID: String) async throws -> Profile
    func updateOnboardingAgeConfirm(userID: String) async throws
    func updateOnboardingAgreements(userID: String) async throws
    func updateOnboardingProfile(userID: String, displayName: String) async throws
    func fetchOpenCohorts() async throws -> [Cohort]
    func fetchApplications(userID: String) async throws -> [CohortApplication]
    func submitApplication(_ submission: ApplicationSubmission) async throws -> CohortApplication
    func fetchMembership(userID: String) async throws -> CohortMembership?
    func fetchCircleID(userID: String, cohortID: String) async throws -> String?
}

enum AuthInputNormalizer {
    static func normalizedEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
