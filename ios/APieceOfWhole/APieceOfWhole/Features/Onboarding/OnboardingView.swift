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
    }
}

struct AgeConfirmView: View {
    let onContinue: () -> Void
    @State private var confirmed = false
    @State private var isLoading = false
    @Environment(AppState.self) var appState

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Text("Before we begin")
                        .font(.powTitle)
                        .foregroundStyle(Color.powForeground)

                    Text("This program is designed for adults. By continuing, you confirm you are 18 years of age or older.")
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                        .multilineTextAlignment(.center)

                    Text("This app is not therapy, not medical care, and is not a crisis service. If you are in crisis, please contact 988.")
                        .font(.powCaption)
                        .foregroundStyle(Color.powMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Toggle(isOn: $confirmed) {
                    Text("I confirm I am 18 years of age or older")
                        .font(.powBody)
                        .foregroundStyle(Color.powForeground)
                }
                .tint(Color.powSage)

                Spacer()

                POWButton(title: "Continue", isLoading: isLoading) {
                    Task { await confirmAge() }
                }
                .disabled(!confirmed)
                .opacity(confirmed ? 1 : 0.5)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 28)
        }
        .navigationTitle("Welcome")
        .navigationBarHidden(true)
    }

    private func confirmAge() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        isLoading = true
        let timestamp = ISO8601DateFormatter().string(from: Date())
        try? await SupabaseService.shared.updateOnboardingAgeConfirm(userID: userID, timestamp: timestamp)
        isLoading = false
        onContinue()
    }
}

struct AgreementsView: View {
    let onContinue: () -> Void
    @State private var termsAccepted = false
    @State private var privacyAccepted = false
    @State private var communityAccepted = false
    @State private var isLoading = false
    @Environment(AppState.self) var appState

    var allAccepted: Bool { termsAccepted && privacyAccepted && communityAccepted }

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Agreements")
                                .font(.powTitle)
                                .foregroundStyle(Color.powForeground)
                            Text("Please review and accept the following before continuing.")
                                .font(.powBody)
                                .foregroundStyle(Color.powMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 16) {
                            AgreementToggle(label: "I agree to the Terms of Service", isOn: $termsAccepted)
                            AgreementToggle(label: "I agree to the Privacy Policy", isOn: $privacyAccepted)
                            AgreementToggle(label: "I agree to the Community Guidelines", isOn: $communityAccepted)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                POWButton(title: "Accept & Continue", isLoading: isLoading) {
                    Task { await acceptAgreements() }
                }
                .disabled(!allAccepted)
                .opacity(allAccepted ? 1 : 0.5)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Agreements")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func acceptAgreements() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        isLoading = true
        let timestamp = ISO8601DateFormatter().string(from: Date())
        try? await SupabaseService.shared.updateOnboardingAgreements(userID: userID, timestamp: timestamp)
        isLoading = false
        onContinue()
    }
}

struct AgreementToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .font(.powBody)
                .foregroundStyle(Color.powForeground)
        }
        .tint(Color.powSage)
        .padding(16)
        .background(Color.powSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.powBorder, lineWidth: 1)
        )
    }
}

struct ProfileSetupView: View {
    let onComplete: () -> Void
    @State private var displayName = ""
    @State private var isLoading = false
    @Environment(AppState.self) var appState

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("How shall we know you?")
                        .font(.powTitle)
                        .foregroundStyle(Color.powForeground)
                    Text("This name will appear in your cohort circle.")
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                POWTextField(label: "Display Name", text: $displayName, placeholder: "Your name or nickname")

                Spacer()

                POWButton(title: "Finish Setup", isLoading: isLoading) {
                    Task { await saveProfile() }
                }
                .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Your Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveProfile() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        isLoading = true
        let timestamp = ISO8601DateFormatter().string(from: Date())
        try? await SupabaseService.shared.updateOnboardingProfile(userID: userID, displayName: displayName, timestamp: timestamp)
        isLoading = false
        onComplete()
    }
}
