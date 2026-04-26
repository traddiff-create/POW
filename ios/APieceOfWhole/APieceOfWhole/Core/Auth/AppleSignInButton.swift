import AuthenticationServices
import CryptoKit
import SwiftUI

/// Apple's HIG-compliant Sign in with Apple button. Uses SwiftUI's native
/// `SignInWithAppleButton` — required by App Store guideline 4.8 / Apple HIG
/// when offering Sign in with Apple alongside other providers.
///
/// Generates a random nonce per request, hashes it for Apple, retains the raw
/// value to send to Supabase for ID token verification.
struct AppleSignInButton: View {
    let onCredential: (AppleIDCredentialPayload) -> Void
    let onError: (SignInWithAppleError) -> Void
    var label: SignInWithAppleButton.Label = .continue

    @Environment(\.colorScheme) private var colorScheme
    @State private var rawNonce: String = ""

    var body: some View {
        SignInWithAppleButton(label) { request in
            let nonce = Self.makeRandomNonce()
            rawNonce = nonce
            request.requestedScopes = [.fullName, .email]
            request.nonce = Self.sha256(nonce)
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                handleAuthorization(authorization)
            case .failure(let error):
                handleError(error)
            }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 50)
        .accessibilityIdentifier("apple.signInButton")
    }

    private func handleAuthorization(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            onError(.missingIdentityToken)
            return
        }
        guard let tokenData = credential.identityToken else {
            onError(.missingIdentityToken)
            return
        }
        guard let token = String(data: tokenData, encoding: .utf8) else {
            onError(.invalidIdentityTokenEncoding)
            return
        }
        guard !rawNonce.isEmpty else {
            onError(.missingIdentityToken)
            return
        }

        let payload = AppleIDCredentialPayload(
            userIdentifier: credential.user,
            identityToken: token,
            rawNonce: rawNonce,
            email: credential.email,
            fullName: credential.fullName
        )
        rawNonce = ""
        onCredential(payload)
    }

    private func handleError(_ error: Error) {
        if let asError = error as? ASAuthorizationError, asError.code == .canceled {
            return
        }
        onError(.underlying(error))
    }

    private static func makeRandomNonce(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        guard status == errSecSuccess else {
            return UUID().uuidString.replacingOccurrences(of: "-", with: "")
        }
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private static func sha256(_ input: String) -> String {
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
