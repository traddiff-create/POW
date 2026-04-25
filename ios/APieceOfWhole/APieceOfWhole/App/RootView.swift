import SwiftUI

struct RootView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        if appState.isLoadingSession {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.powBackground)
        } else if !appState.isSignedIn {
            PublicNavigationView()
        } else if !appState.isOnboarded {
            OnboardingView()
        } else if !appState.hasActiveCohort {
            ApplicationNavigationView()
        } else {
            MainTabView()
        }
    }
}
