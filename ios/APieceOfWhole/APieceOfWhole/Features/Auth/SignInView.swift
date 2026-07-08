import SwiftUI

struct SignInView: View {
    @Environment(AppState.self) var appState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: String?
    @State private var isAppleSigningIn = false

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Welcome back")
                            .font(.hereTitle)
                            .foregroundStyle(Color.hereForeground)
                        Text("Sign in to continue your journey")
                            .font(.hereBody)
                            .foregroundStyle(Color.hereMuted)
                    }
                    .padding(.top, 32)

                    AppleSignInButton(
                        onCredential: { payload in
                            Task { await signInWithApple(payload) }
                        },
                        onError: { signInError in
                            error = signInError.errorDescription
                        },
                        label: .signIn
                    )
                    .opacity(isAppleSigningIn ? 0.6 : 1)
                    .disabled(isAppleSigningIn)

                    HStack {
                        Rectangle().fill(Color.hereBorder).frame(height: 1)
                        Text("or")
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereMuted)
                        Rectangle().fill(Color.hereBorder).frame(height: 1)
                    }

                    VStack(spacing: 16) {
                        HereTextField(label: "Email", text: $email, keyboardType: .emailAddress, accessibilityID: "signIn.emailField")
                        HereTextField(label: "Password", text: $password, isSecure: true, accessibilityID: "signIn.passwordField")
                    }

                    if let error {
                        Text(error)
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("signIn.errorText")
                    }

                    HereButton(title: "Sign In", isLoading: isLoading) {
                        Task { await signIn() }
                    }
                    .accessibilityIdentifier("signIn.submitButton")
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signIn() async {
        isLoading = true
        error = nil
        do {
            try await appState.signIn(email: email, password: password)
        } catch {
            self.error = AppPublicError.message(for: error, context: .signIn)
        }
        isLoading = false
    }

    private func signInWithApple(_ payload: AppleIDCredentialPayload) async {
        isAppleSigningIn = true
        error = nil
        do {
            try await appState.signInWithApple(credential: payload)
        } catch {
            self.error = AppPublicError.message(for: error, context: .appleSignIn)
        }
        isAppleSigningIn = false
    }
}
