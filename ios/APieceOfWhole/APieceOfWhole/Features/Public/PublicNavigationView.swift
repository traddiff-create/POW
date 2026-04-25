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

                        Text("A structured journey toward regulation,\nresilience, and civic participation.")
                            .font(.powBody)
                            .foregroundStyle(Color.powMuted)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        POWButton(title: "Apply to Join") {
                            onCreateAccount()
                        }

                        POWButton(title: "Sign In", style: .ghost) {
                            onSignIn()
                        }
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
}
