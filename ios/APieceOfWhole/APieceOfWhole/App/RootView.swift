import SwiftUI

struct RootView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        if let configurationError = Config.supabaseConfigurationError {
            ConfigurationErrorView(message: configurationError.localizedDescription)
        } else if appState.isLoadingSession {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.powBackground)
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
            Color.powBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.powError)

                Text("Configuration Error")
                    .font(.powTitle)
                    .foregroundStyle(Color.powForeground)

                Text(message)
                    .font(.powBody)
                    .foregroundStyle(Color.powMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
        }
    }
}
