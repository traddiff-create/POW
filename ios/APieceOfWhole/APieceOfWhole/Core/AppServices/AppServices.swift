import Foundation
import OSLog
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

enum AppPublicErrorContext: String {
    case configuration
    case signIn
    case createAccount
    case appleSignIn
    case onboarding
    case cohorts
    case application
    case payment
    case restorePurchase
    case settings
    case accountDeletion
    case practice
    case civic
    case circle
    case journal
    case learn
    case myPiece
    case management
    case checkIn
    case guest
    case general
}

enum AppPublicError {
    private static let logger = Logger(
        subsystem: "com.traddifftech.apieceofwhole",
        category: "PublicError"
    )

    static func message(
        for error: Error,
        context: AppPublicErrorContext = .general
    ) -> String {
        log(error, context: context)

        if let inputError = error as? AuthInputError {
            return inputError.localizedDescription
        }

        if let dataError = error as? AppDataError {
            return dataError.localizedDescription
        }

        if let purchaseError = error as? PurchaseError {
            return purchaseError.localizedDescription
        }

        if let appleError = error as? SignInWithAppleError {
            switch appleError {
            case .missingIdentityToken, .invalidIdentityTokenEncoding:
                return appleError.localizedDescription
            case .underlying:
                return fallbackMessage(for: context)
            }
        }

        if error is AppConfigurationError {
            return fallbackMessage(for: .configuration)
        }

        if error is AuthError {
            return fallbackMessage(for: context)
        }

        return fallbackMessage(for: context)
    }

    static func configurationMessage() -> String {
        fallbackMessage(for: .configuration)
    }

    private static func log(_ error: Error, context: AppPublicErrorContext) {
        logger.error(
            "User-facing error mapped. context=\(context.rawValue, privacy: .public) type=\(String(describing: type(of: error)), privacy: .public) message=\(error.localizedDescription, privacy: .private)"
        )
    }

    private static func fallbackMessage(for context: AppPublicErrorContext) -> String {
        switch context {
        case .configuration:
            return "The app is not fully configured. Please contact support."
        case .signIn:
            return "Could not sign in. Please check your details and try again."
        case .createAccount:
            return "Could not create your account. Please try again."
        case .appleSignIn:
            return "Could not complete Sign in with Apple. Please try again."
        case .onboarding:
            return "Could not save your onboarding step. Please try again."
        case .cohorts:
            return "Could not load cohorts. Please try again."
        case .application:
            return "Could not save your application. Please try again."
        case .payment:
            return "Could not complete enrollment. Please try again."
        case .restorePurchase:
            return "Could not restore your purchase. Please try again."
        case .settings:
            return "Could not save your settings. Please try again."
        case .accountDeletion:
            return "Could not submit your request. Please try again."
        case .practice:
            return "Could not load practices. Please try again."
        case .civic:
            return "Could not load civic lessons. Please try again."
        case .circle:
            return "Could not update Circle. Please try again."
        case .journal:
            return "Could not save your journal entry. Please try again."
        case .learn:
            return "Could not load the Learn library. Please try again."
        case .myPiece:
            return "Could not save My Piece. Please try again."
        case .management:
            return "Could not complete that management action. Please try again."
        case .checkIn:
            return "Could not save your check-in. Please try again."
        case .guest:
            return "Guest access is unavailable right now. Please sign in or create an account."
        case .general:
            return "Something went wrong. Please try again."
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
