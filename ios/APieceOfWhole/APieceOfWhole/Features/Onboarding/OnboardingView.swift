import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) var appState
    @State private var step: OnboardingStep = .ageConfirm

    var body: some View {
        NavigationStack {
            switch step {
            case .ageConfirm:
                AgeConfirmView { step = .agreements }
            case .agreements:
                AgreementsView { step = .profileSetup }
            case .profileSetup:
                ProfileSetupView {
                    Task { await appState.refreshProfile() }
                }
            case .complete:
                EmptyView()
            }
        }
        .onAppear {
            step = OnboardingStep(rawValue: appState.profile?.onboardingStep ?? "") ?? .ageConfirm
        }
    }
}

struct AgeConfirmView: View {
    let onContinue: () -> Void
    @State private var confirmed = false
    @State private var isLoading = false
    @State private var error: String?
    @Environment(AppState.self) var appState

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Text("Before we begin")
                        .font(.hereTitle)
                        .foregroundStyle(Color.hereForeground)

                    Text("This program is designed for adults. By continuing, you confirm you are 18 years of age or older.")
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                        .multilineTextAlignment(.center)

                    Text(HerePhilosophy.onboardingCopy)
                        .font(.hereBody)
                        .foregroundStyle(Color.hereForeground)
                        .multilineTextAlignment(.center)

                    Text("This app is not therapy, not medical care, and is not a crisis service. If you are in crisis, please contact 988.")
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Toggle(isOn: $confirmed) {
                    Text("I confirm I am 18 years of age or older")
                        .font(.hereBody)
                        .foregroundStyle(Color.hereForeground)
                }
                .tint(Color.hereSage)
                .accessibilityIdentifier("onboarding.ageToggle")

                if let error {
                    Text(error)
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereError)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("onboarding.ageErrorText")
                }

                Spacer()

                HereButton(title: "Continue", isLoading: isLoading) {
                    Task { await confirmAge() }
                }
                .disabled(!confirmed || isLoading)
                .opacity(confirmed ? 1 : 0.5)
                .accessibilityIdentifier("onboarding.ageContinueButton")
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 28)
        }
        .navigationTitle("Welcome")
        .navigationBarHidden(true)
    }

    private func confirmAge() async {
        isLoading = true
        error = nil
        do {
            try await appState.confirmAdult()
            onContinue()
        } catch {
            self.error = AppPublicError.message(for: error, context: .onboarding)
        }
        isLoading = false
    }
}

struct AgreementsView: View {
    let onContinue: () -> Void
    @State private var termsAccepted = false
    @State private var privacyAccepted = false
    @State private var communityAccepted = false
    @State private var isLoading = false
    @State private var error: String?
    @Environment(AppState.self) var appState

    var allAccepted: Bool { termsAccepted && privacyAccepted && communityAccepted }

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Agreements")
                                .font(.hereTitle)
                                .foregroundStyle(Color.hereForeground)
                            Text("These agreements protect the conditions for honest, caring, nonclinical community practice.")
                                .font(.hereBody)
                                .foregroundStyle(Color.hereMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 16) {
                            AgreementToggle(label: "I agree to the Terms of Service", accessibilityID: "onboarding.termsToggle", isOn: $termsAccepted)
                            AgreementToggle(label: "I agree to the Privacy Policy", accessibilityID: "onboarding.privacyToggle", isOn: $privacyAccepted)
                            AgreementToggle(label: "I agree to the Community Guidelines", accessibilityID: "onboarding.communityToggle", isOn: $communityAccepted)
                        }

                        if let error {
                            Text(error)
                                .font(.hereCaption)
                                .foregroundStyle(Color.hereError)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accessibilityIdentifier("onboarding.agreementsErrorText")
                        }
                    }
                    .padding(.horizontal, 24)
                }

                HereButton(title: "Accept & Continue", isLoading: isLoading) {
                    Task { await acceptAgreements() }
                }
                .disabled(!allAccepted || isLoading)
                .opacity(allAccepted ? 1 : 0.5)
                .accessibilityIdentifier("onboarding.agreementsContinueButton")
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Agreements")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func acceptAgreements() async {
        isLoading = true
        error = nil
        do {
            try await appState.acceptAgreements()
            onContinue()
        } catch {
            self.error = AppPublicError.message(for: error, context: .onboarding)
        }
        isLoading = false
    }
}

struct AgreementToggle: View {
    let label: String
    let accessibilityID: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .font(.hereBody)
                .foregroundStyle(Color.hereForeground)
        }
        .tint(Color.hereSage)
        .accessibilityIdentifier(accessibilityID)
        .padding(16)
        .background(Color.hereSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.hereBorder, lineWidth: 1)
        )
    }
}

struct ProfileSetupView: View {
    let onComplete: () -> Void
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var error: String?
    @State private var hasPrefilled = false
    @Environment(AppState.self) var appState

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("How shall we know you?")
                        .font(.hereTitle)
                        .foregroundStyle(Color.hereForeground)
                    Text(appState.isGuest ? "You can add a name now or continue as Guest." : "This name will appear in your cohort circle, where connection is practiced with care.")
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                HereTextField(label: "Display Name", text: $displayName, placeholder: "Your name or nickname", accessibilityID: "onboarding.displayNameField")

                if let error {
                    Text(error)
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("onboarding.profileErrorText")
                }

                Spacer()

                HereButton(title: "Finish Setup", isLoading: isLoading) {
                    Task { await saveProfile() }
                }
                .disabled((!appState.isGuest && displayName.trimmingCharacters(in: .whitespaces).isEmpty) || isLoading)
                .accessibilityIdentifier("onboarding.finishButton")
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Your Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !hasPrefilled else { return }
            hasPrefilled = true
            if let suggested = appState.consumePendingDisplayName(),
               displayName.trimmingCharacters(in: .whitespaces).isEmpty {
                displayName = suggested
            } else if let existing = appState.profile?.displayName,
                      !existing.trimmingCharacters(in: .whitespaces).isEmpty,
                      displayName.trimmingCharacters(in: .whitespaces).isEmpty {
                displayName = existing
            }
        }
    }

    private func saveProfile() async {
        isLoading = true
        error = nil
        do {
            try await appState.completeOnboarding(displayName: displayName)
            onComplete()
        } catch {
            self.error = AppPublicError.message(for: error, context: .onboarding)
        }
        isLoading = false
    }
}
