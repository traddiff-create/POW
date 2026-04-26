import SwiftUI

struct ApplicationNavigationView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            CohortListView(path: $path)
                .navigationDestination(for: Cohort.self) { cohort in
                    ApplyFormView(cohort: cohort, path: $path)
                }
                .navigationDestination(for: CohortApplication.self) { application in
                    ApplicationStatusView(application: application)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        ApplicantAccountMenu()
                    }
                }
        }
    }
}

struct ApplicantAccountMenu: View {
    @Environment(AppState.self) var appState
    @State private var isSigningOut = false

    var body: some View {
        Menu {
            Button(role: .destructive) {
                Task { await signOut() }
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .accessibilityIdentifier("applicant.signOutButton")
        } label: {
            Label("Account", systemImage: "person.crop.circle")
        }
        .accessibilityIdentifier("applicant.accountMenu")
    }

    private func signOut() async {
        guard !isSigningOut else { return }
        isSigningOut = true
        try? await appState.signOut()
        isSigningOut = false
    }
}
