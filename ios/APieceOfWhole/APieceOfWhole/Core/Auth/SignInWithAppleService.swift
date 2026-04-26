import Foundation

/// Credential payload returned from a successful Sign in with Apple flow.
/// Apple only returns `email` and `fullName` on the very first sign-in for a
/// given Apple ID — subsequent sign-ins drop these fields. Capture them
/// immediately and persist downstream rather than expecting them again.
struct AppleIDCredentialPayload: Sendable {
    let userIdentifier: String
    let identityToken: String
    let rawNonce: String
    let email: String?
    let fullName: PersonNameComponents?

    var displayName: String? {
        guard let fullName else { return nil }
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .default
        let formatted = formatter.string(from: fullName).trimmingCharacters(in: .whitespacesAndNewlines)
        return formatted.isEmpty ? nil : formatted
    }
}

enum SignInWithAppleError: LocalizedError {
    case missingIdentityToken
    case invalidIdentityTokenEncoding
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .missingIdentityToken:
            return "Apple did not return an identity token. Please try again."
        case .invalidIdentityTokenEncoding:
            return "Apple's identity token was malformed. Please try again."
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
