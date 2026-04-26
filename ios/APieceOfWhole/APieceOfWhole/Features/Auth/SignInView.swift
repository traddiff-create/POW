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
            Color.powBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Welcome back")
                            .font(.powTitle)
                            .foregroundStyle(Color.powForeground)
                        Text("Sign in to continue your journey")
                            .font(.powBody)
                            .foregroundStyle(Color.powMuted)
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
                        Rectangle().fill(Color.powBorder).frame(height: 1)
                        Text("or")
                            .font(.powCaption)
                            .foregroundStyle(Color.powMuted)
                        Rectangle().fill(Color.powBorder).frame(height: 1)
                    }

                    VStack(spacing: 16) {
                        POWTextField(label: "Email", text: $email, keyboardType: .emailAddress, accessibilityID: "signIn.emailField")
                        POWTextField(label: "Password", text: $password, isSecure: true, accessibilityID: "signIn.passwordField")
                    }

                    if let error {
                        Text(error)
                            .font(.powCaption)
                            .foregroundStyle(Color.powError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("signIn.errorText")
                    }

                    POWButton(title: "Sign In", isLoading: isLoading) {
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
