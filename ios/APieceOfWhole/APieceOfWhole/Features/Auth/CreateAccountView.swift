import SwiftUI

struct CreateAccountView: View {
    @Environment(AppState.self) var appState
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Create an account")
                            .font(.powTitle)
                            .foregroundStyle(Color.powForeground)
                        Text("Start your journey with A Piece of Whole")
                            .font(.powBody)
                            .foregroundStyle(Color.powMuted)
                    }
                    .padding(.top, 32)

                    VStack(spacing: 16) {
                        POWTextField(label: "Email", text: $email, keyboardType: .emailAddress)
                        POWTextField(label: "Password", text: $password, isSecure: true)
                        POWTextField(label: "Confirm Password", text: $confirmPassword, isSecure: true)
                    }

                    if let error {
                        Text(error)
                            .font(.powCaption)
                            .foregroundStyle(Color.powError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    POWButton(title: "Create Account", isLoading: isLoading) {
                        Task { await createAccount() }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func createAccount() async {
        guard password == confirmPassword else {
            error = "Passwords do not match."
            return
        }
        isLoading = true
        error = nil
        do {
            _ = try await AuthService.shared.signUp(email: email, password: password)
            await appState.load()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
