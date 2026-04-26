import SwiftUI

struct CreateAccountView: View {
    @Environment(AppState.self) var appState
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var error: String?
    @State private var confirmationMessage: String?
    @State private var isAppleSigningIn = false

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Create an account")
                            .font(.powTitle)
                            .foregroundStyle(Color.powForeground)
                        Text(POWPhilosophy.onboardingCopy)
                            .font(.powBody)
                            .foregroundStyle(Color.powMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)

                    AppleSignInButton(
                        onCredential: { payload in
                            Task { await signUpWithApple(payload) }
                        },
                        onError: { signInError in
                            error = signInError.errorDescription
                        },
                        label: .signUp
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
                        POWTextField(label: "Email", text: $email, keyboardType: .emailAddress, accessibilityID: "create.emailField")
                        POWTextField(label: "Password", text: $password, isSecure: true, accessibilityID: "create.passwordField")
                        POWTextField(label: "Confirm Password", text: $confirmPassword, isSecure: true, accessibilityID: "create.confirmPasswordField")
                    }

                    if let error {
                        Text(error)
                            .font(.powCaption)
                            .foregroundStyle(Color.powError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("create.errorText")
                    }

                    if let confirmationMessage {
                        Text(confirmationMessage)
                            .font(.powCallout)
                            .foregroundStyle(Color.powSage)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("create.confirmationText")
                    }

                    POWButton(title: "Create Account", isLoading: isLoading) {
                        Task { await createAccount() }
                    }
                    .accessibilityIdentifier("create.submitButton")
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func createAccount() async {
        isLoading = true
        error = nil
        confirmationMessage = nil
        do {
            switch try await appState.createAccount(email: email, password: password, confirmPassword: confirmPassword) {
            case .signedIn:
                break
            case .emailConfirmationRequired(let normalizedEmail):
                confirmationMessage = "Check \(normalizedEmail) to confirm your account, then sign in."
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func signUpWithApple(_ payload: AppleIDCredentialPayload) async {
        isAppleSigningIn = true
        error = nil
        confirmationMessage = nil
        do {
            try await appState.signInWithApple(credential: payload)
        } catch {
            self.error = error.localizedDescription
        }
        isAppleSigningIn = false
    }
}
