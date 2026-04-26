import SwiftUI

struct PublicNavigationView: View {
    @State private var showSignIn = false
    @State private var showCreateAccount = false

    var body: some View {
        NavigationStack {
            WelcomeView(
                onSignIn: { showSignIn = true },
                onCreateAccount: { showCreateAccount = true }
            )
            .navigationDestination(isPresented: $showSignIn) {
                SignInView()
            }
            .navigationDestination(isPresented: $showCreateAccount) {
                CreateAccountView()
            }
        }
    }
}

struct WelcomeView: View {
    let onSignIn: () -> Void
    let onCreateAccount: () -> Void
    @Environment(AppState.self) var appState
    @State private var isContinuingAsGuest = false
    @State private var guestError: String?
    @State private var isAppleSigningIn = false
    @State private var appleError: String?

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("A Piece of Whole")
                            .font(.powLargeTitle)
                            .foregroundStyle(Color.powForeground)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("welcome.title")

                        Text(POWPhilosophy.signatureLine)
                            .font(.powTitle2)
                            .foregroundStyle(Color.powSage)
                            .multilineTextAlignment(.center)

                        Text(POWPhilosophy.welcomeCopy)
                            .font(.powBody)
                            .foregroundStyle(Color.powMuted)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        if let loadError = appState.loadError {
                            Text(loadError)
                                .font(.powCaption)
                                .foregroundStyle(Color.powError)
                                .multilineTextAlignment(.center)
                                .accessibilityIdentifier("welcome.loadErrorText")
                        }

                        AppleSignInButton(
                            onCredential: { payload in
                                Task { await signInWithApple(payload) }
                            },
                            onError: { error in
                                appleError = AppPublicError.message(for: error, context: .appleSignIn)
                            },
                            label: .continue
                        )
                        .opacity(isAppleSigningIn ? 0.6 : 1)
                        .disabled(isAppleSigningIn)

                        if let appleError {
                            Text(appleError)
                                .font(.powCaption)
                                .foregroundStyle(Color.powError)
                                .multilineTextAlignment(.center)
                                .accessibilityIdentifier("welcome.appleErrorText")
                        }

                        POWButton(title: "Continue without Account", isLoading: isContinuingAsGuest) {
                            Task { await continueAsGuest() }
                        }
                        .accessibilityIdentifier("welcome.guestButton")

                        POWButton(title: "Continue with Email", style: .ghost) {
                            onCreateAccount()
                        }
                        .accessibilityIdentifier("welcome.createAccountButton")

                        POWButton(title: "Sign In with Email", style: .ghost) {
                            onSignIn()
                        }
                        .accessibilityIdentifier("welcome.signInButton")

                        if let guestError {
                            Text(guestError)
                                .font(.powCaption)
                                .foregroundStyle(Color.powError)
                                .multilineTextAlignment(.center)
                                .accessibilityIdentifier("welcome.guestErrorText")
                        }

                        NavigationLink(destination: PhilosophyView()) {
                            Label("Working Philosophy", systemImage: "circle.hexagongrid")
                                .font(.powCallout)
                                .foregroundStyle(Color.powSage)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 28)

                Spacer()

                Text("This app is not therapy, not medical care, and is not a crisis service.\nIf you are in crisis, contact 988.")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
    }

    private func continueAsGuest() async {
        isContinuingAsGuest = true
        guestError = nil
        do {
            try await appState.continueAsGuest()
        } catch {
            guestError = AppPublicError.message(for: error, context: .guest)
        }
        isContinuingAsGuest = false
    }

    private func signInWithApple(_ payload: AppleIDCredentialPayload) async {
        isAppleSigningIn = true
        appleError = nil
        do {
            try await appState.signInWithApple(credential: payload)
        } catch {
            appleError = AppPublicError.message(for: error, context: .appleSignIn)
        }
        isAppleSigningIn = false
    }
}
