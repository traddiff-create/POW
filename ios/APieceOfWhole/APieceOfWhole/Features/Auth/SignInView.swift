import SwiftUI

struct SignInView: View {
    @Environment(AppState.self) var appState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: String?

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

                    VStack(spacing: 16) {
                        POWTextField(label: "Email", text: $email, keyboardType: .emailAddress)
                        POWTextField(label: "Password", text: $password, isSecure: true)
                    }

                    if let error {
                        Text(error)
                            .font(.powCaption)
                            .foregroundStyle(Color.powError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    POWButton(title: "Sign In", isLoading: isLoading) {
                        Task { await signIn() }
                    }
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
            let session = try await AuthService.shared.signIn(email: email, password: password)
            appState.session = session
            await appState.load()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
