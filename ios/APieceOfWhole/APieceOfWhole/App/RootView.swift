import SwiftUI

struct RootView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        if let configurationError = Config.supabaseConfigurationError {
            ConfigurationErrorView(
                message: AppPublicError.message(for: configurationError, context: .configuration)
            )
        } else if appState.isLoadingSession {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.hereBackground)
        } else if !appState.isSignedIn {
            PublicNavigationView()
        } else if appState.isGuest && !appState.isOnboarded {
            OnboardingView()
        } else if appState.isGuest {
            MainTabView()
        } else if !appState.isOnboarded {
            OnboardingView()
        } else if !appState.hasActiveCohort {
            ApplicationNavigationView()
        } else {
            MainTabView()
        }
    }
}

private struct ConfigurationErrorView: View {
    let message: String

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.hereError)

                Text("Configuration Error")
                    .font(.hereTitle)
                    .foregroundStyle(Color.hereForeground)

                Text(message)
                    .font(.hereBody)
                    .foregroundStyle(Color.hereMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
        }
    }
}
